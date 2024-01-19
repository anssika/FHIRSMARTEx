Class FHIRSMARTEx.OAuth2.Server.Authenticate Extends %OAuth2.Server.Authenticate
{

/// 1 = do direct login (do not present a page for username/password), 0 = do not do directlogin
Parameter DODIRECTLOGIN = 0;

Parameter DIRECTLOGINUSER = "_SYSTEM";

Parameter DIRECTLOGINPASSWORD = "sys";

/// 1 = add trace message, 0 = do not add trace messages
Parameter DOTRACE = 0;

/// Only some tracing added
/// 
/// If DirectLogin chooses to do authentication by some means other than display of the user login form,
/// DirectLogin sets the username and password arguments which will later be used
/// to obtain the properties associated with the access token and to generate the token.
/// If username is set to $char(0), then the access_denied error will be returned.<br>
/// This method may directly look at the request properties and set properties
/// for GenerateAccessToken using the properties array argument.
ClassMethod DirectLogin(scope As %ArrayOfDataTypes, properties As %OAuth2.Server.Properties, Output username As %String, Output password As %String) As %Status
{
	//Return ##Super(scope, properties, username, password)

	If (..#DOTRACE) { 
		// Just debugging
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append(..%ClassName(1)_".DirectLogin:")
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.GetClaimValue(""sub"") = " _ properties.GetClaimValue("sub"))
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  properties.RequestProperties.GetAt(""launch"") = " _ properties.RequestProperties.GetAt("launch"))
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  username / password = " _ username _ " / " _ password)
	}

	// By default: no direct login
	Set username=""
	Set password=""

	If (..#DODIRECTLOGIN) {
		Set username = ..#DIRECTLOGINUSER
		Set password = ..#DIRECTLOGINPASSWORD
	}

	If (..#DOTRACE) Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  >>>> returning username / password = " _ username _ " / " _password)

	Quit $$$OK
}

}
