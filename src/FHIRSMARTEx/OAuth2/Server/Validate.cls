Class FHIRSMARTEx.OAuth2.Server.Validate Extends %OAuth2.Server.Validate
{

/// 1 = add trace message, 0 = do not add trace messages
Parameter DOTRACE = 0;

/// Non-inherited utility method to enable tracing of array values
ClassMethod ArrayToString(pArray As %ArrayOfDataTypes, pValueIsList As %Boolean = 0) As %String
{
	#Dim tString = ""

	#Dim tKey, tValue As %String = ""
	Set tValue = pArray.GetNext(.tKey)
	While (tKey '= "") {
		If (tString '= "") Set tString = tString _ ", "
		If (pValueIsList) {
			Set tString = tString _ tKey _ "=" _ $listget(tValue,2) _ "(" _ $listget(tValue,1) _ ")"
		}
		Else {
			Set tString = tString _ tKey _ "=" _ tValue
		}
		Set tValue = pArray.GetNext(.tKey)
	}
	Return tString
}

/// Non-inherited utility method to add trace
ClassMethod Trace(scope As %ArrayOfDataTypes, properties As %OAuth2.Server.Properties, pEnd As %Boolean = 0)
{
	If (..#DOTRACE)

	Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  scope: " _ ..ArrayToString(scope))
	Do:'pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.%Id(): " _ properties.%Id())
	Do:'pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.RequestProperties.GetAt(""launch""): " _ properties.RequestProperties.GetAt("launch"))
	Do:'pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.RequestProperties: " _ ..ArrayToString(properties.RequestProperties))
	Do:pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.ResponseProperties: " _ ..ArrayToString(properties.ResponseProperties))
	Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.CustomProperties: " _ ..ArrayToString(properties.CustomProperties))
	Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.ClaimValues: " _ ..ArrayToString(properties.ClaimValues, 1))
	Do:pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.JWTClaims: " _ ..ArrayToString(properties.JWTClaims))
	Do:pEnd ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.IntrospectionClaims: " _ ..ArrayToString(properties.IntrospectionClaims))
}

/// Non-inherited utility method to add a claim to the access token, also to be returned by introspection
ClassMethod AddClaim(Output properties As %OAuth2.Server.Properties, pClaim As %String, pValue As %String)
{
	If (..#DOTRACE) Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  AddClaim starts: pClaim = " _ pClaim _ ", pValue = " _ pValue)
	#Dim tClaim As %OAuth2.Server.Claim = ##class(%OAuth2.Server.Claim).%New()
	Do properties.JWTClaims.SetAt(tClaim, pClaim)
	Do properties.IntrospectionClaims.SetAt(tClaim, pClaim)
	Do properties.SetClaimValue(pClaim, pValue)
}

/// Non-inherited utility method to process launch context
ClassMethod ProcessLaunchContext(scope As %ArrayOfDataTypes, Output properties As %OAuth2.Server.Properties)
{
	If (..#DOTRACE) Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  ProcessLaunchContext starts")

	#Dim tPatientId As %String = ""
	If (scope.IsDefined("launch") || scope.IsDefined("launch/patient")) {

		Set tPatientId = "9000"	// Provided as an example
		If (properties.GetClaimValue("sub") = "sepposokru") Set tPatientId = "2821934"	// Provided as an example

		If (..#DOTRACE) Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  >>>> Adding to JWTClaims and IntrospectionClaims: patient = " _ tPatientId)
		Do ..AddClaim(.properties, "patient", tPatientId)
		If (..#DOTRACE) Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  >>>> Adding to  ResponseProperties: patient = " _ tPatientId)
		Do properties.ResponseProperties.SetAt(tPatientId, "patient")
	}
}

/// Your custom ValidateUser method must return true (1) only if the username and password refer to a valid user
/// based on whatever criteria you choose to implement.  It must return false in other cases. <p>
/// If password="", then the user is already logged into an existing session and the password
/// does not need to be validated.<p>
/// In addition, this method receives the properties array and can further modify it;
/// this correspond to the Properties property of %OAuth2.Server.Token. 
/// The authorization server will always add the "iss" (URL of authorization server),
/// "sub" (client_id), and "exp" (expiration time in seconds since December 31st, 1840)
/// to ClaimValues and "client_id" (client_id of the requesting client) to CusotmProperties 
/// after return from ValidateUser if they have not already been added.<p>
/// This sample ValidateUser method validates the user based on the users for this instance.
/// Set the use2fa output parameter to 1 (true) to indicate two factor authentication should be used. In this case
/// the authenticate page will ask the user to enter a security code, which will be validated by <Method>Validate2FA</Method>. 
ClassMethod ValidateUser(username As %String, password As %String, scope As %ArrayOfDataTypes, properties As %OAuth2.Server.Properties, Output sc As %Status, Output use2fa As %Boolean = 0) As %Boolean
{
	If (..#DOTRACE) { 
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".ValidateUser starts: scope = " _ scope _ " properties = " _ properties)
		Do ..Trace(scope, properties, 0)
	}

	#Dim tValid As %Boolean = ##Super(username, password, scope, properties, .sc, .use2fa)
	Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".ValidateUser: superclas returned " _ tValid)
	If ('tValid) Return tValid

	Do ..ProcessLaunchContext(scope, .properties)

	If (..#DOTRACE) { 
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".ValidateClient ends: scope = " _ scope _ " properties = " _ properties)
		Do ..Trace(scope, properties, 1)
	}

	Quit 1
}

/// The ValidateClient method returns true (1), if the client_id and client_secret refer to a
/// client computer which may use the client credentials grant type based on whatever criteria
/// the method chooses to implement.  This client will already have been verified to be registered 
/// to this authorization server and thus will usually be accepted.
/// ValidateClient populates the properties array argument with any properties needed to generate the access token.
/// This correspond to the Properties arguments of OAuth2.Server.Token.
/// The authorization server will always add the "iss" (URL of authorization server),
/// "sub" (client_id), and "exp" (expiration time in seconds since December 31st, 1840)
/// to ClaimValues and "client_id" (client_id of the requesting client) to CusotmProperties 
/// after return from ValidateUser if they have not already been added.<br>
/// If not valid then false is returned.<br>
/// This default ValidateClient accepts all clients and adds no properties.
ClassMethod ValidateClient(clientId As %String, clientSecret As %String, scope As %ArrayOfDataTypes, Output properties As %OAuth2.Server.Properties, Output sc As %Status) As %Boolean
{
	If (..#DOTRACE) { 
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".ValidateClient starts:")
		Do ..Trace(scope, properties, 0)
	}

	Do ..ProcessLaunchContext(scope, .properties)

	If (..#DOTRACE) { 
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".ValidateClient ends:")
		Do ..Trace(scope, properties, 1)
	}

	Quit 1
}

}
