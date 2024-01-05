Class FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4 Extends (%CSP.Page, FHIRSMARTEx.Setup.OAuth2Common)
{

/// Name of the client configuration
Parameter OAUTH2APPBASENAME = "IRISConfidentialSymmetricV4";

Parameter CLIENTSSLCONFIGNAME = "client";

Parameter RESOURCESPATH = "/fhir/r4";

ClassMethod Scope() As %String
{
	Return "user/*.*"
	Return "system/*.*"
	Return "openid patient/*.* launch/patient/2"
	//Return "openid patient/*.* launch/patient/*"
	//Return "openid patient/*.*"
	//Return "openid user/*.*"
}

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tAccessToken, tIdToken, tResponseProperties As %String
	#Dim tIsAuthorized As %Boolean

	&html<<html><head></head><body>>

	&html<<h3>#(..%ClassName(1))#</h3>>

	Try {

		#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))

		/********************************************************************************
		This call
		*/

		// AC = authorization_code, R = client_credentials. The other grant types not supported by this client are: "implicit", "password", "jwt_authorization"
		Set tGrantType = $Get(%request.Data("grantType", 1), "")

		&html<<p>>
		&html<url parameter </strong>grantType</strong> has value #(tGrantType)#...>
		If (tGrantType = "CR") {
			&html<<br>using grant type client_credentials (CR)>
		}
		ElseIf (tGrantType = "AC") {
			&html<<br>using grant type authorization_code (AC)>
			Set tOAuth2AppName = ..#OAUTH2APPBASENAME _ "AC"
		}
		else {
			&html<<br>using default grant type client_credentials (CR)>
			Set tGrantType = "CR"
		}
		&html<</p>>

		#Dim tOAuth2AppName As %String = ..#OAUTH2APPBASENAME _ tGrantType

		&html<
		<h3>About this page</h3>
		<p>
			tThisPage = #(tThisPage)#<br>
			tOAuth2AppName = #(tOAuth2AppName)#<br>
		</p>>

		/********************************************************************************
		Do we have a client configuration?
		If not, create one and register it with OAuth2 server
		*/

		Do ..CheckCreateClientConfiguration(tOAuth2AppName, "confidential")

		/********************************************************************************
		Test if this client is authorized?
		*/
		Set tIsAuthorized = ..IsAuthorized(tOAuth2AppName, .tAccessToken, .tIdToken, .tResponseProperties)
 
 		// Is authorized?
		If ('tIsAuthorized) {

			/********************************************************************************
			IF NOT authorized
			*/

			#Dim tProperties As %String
			Set tProperties("aud") = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ ..#RESOURCESPATH

			If (tGrantType = "CR") {	// CR = client_credentials

				/********************************************************************************
				Authorize using client credentials
				*/
				&html<
					<h3>Authorizing using client credentials</h3>
					<p>
					Invoking <strong>##class(%SYS.OAuth2.Authorization).GetAccessTokenClient(...)</strong> at #($ZDateTime($H,3))# ...>

				Set tStatus = ##class(%SYS.OAuth2.Authorization).GetAccessTokenClient(tOAuth2AppName, ..Scope(), .tProperties, .tError)
				If ($$$ISERR(tStatus)) {
					&html<<br>the call returnd error status = #(##class(%SYSTEM.OBJ).DisplayError(tStatus))#</p>>
					Return $$$OK  
				}

				/********************************************************************************
				Test if this client is authorized now?
				*/
				Set tIsAuthorized = ..IsAuthorized(tOAuth2AppName, .tAccessToken, .tIdToken, .tResponseProperties)

				// Is authorized?
				If ('tIsAuthorized) {
					&html<<br>After authorization, this client still looks like not authorized!</p>>
					&html<<br>Do not know what to do ...</p>>
					Return $$$OK
				}
			}
			Else {	// AC = authorization_code

				/********************************************************************************
				Create a link for the user to select to do authorisation
				*/
				&html<
					<h3>Getting authorisation endpoint url</h3>
					<p>
					Invoking <strong>##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(...)</strong> at #($ZDateTime($H,3))# ...>

				#Dim tUrl = ##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(tOAuth2AppName, ..Scope(),
																tThisPage,.tProperties,.tIsAuthorized,.tStatus)
															//$Replace(tThisPage, "ClientV2", "Client"),.tProperties,.tIsAuthorized,.tStatus)
				If ($$$ISERR(tStatus)) {
					&html<Call of ##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint( ... ) returned an error:<br>
					<pre>#(##class(%SYSTEM.Status).GetErrorText(tStatus))#</pre>
					</p>>
					Return $$$OK  
				}
				&html<<br>Got the authorization url (below). Please select it</p>> 

				&html<<p><a href='#(tUrl)#'>#(tUrl)#</a></p>>

				Return $$$OK  
			}
		}
		

		/********************************************************************************
		WHEN/IF authorized
		*/

		&html<
			<h3>This client IS authorized<br>either earlier, or because of actions taken previously</h3>>

		&html<<p>This is what we have after the previous invocation:<br>
			<textarea id="authorized" rows="2" cols="100">>
			Write "tAccessToken = " _ tAccessToken, !!
			Write "tIdToken = " _ tIdToken, !!
			Write "Output of ZWrite tResponseProperties:", !!
			ZWrite tResponseProperties
		&html<</textarea></p>>


		/********************************************************************************
		Call introspection
		*/

		If (1) {	// This call is not needed in order to continue
			&html<
				<h3>Introspection</h3>
				<p>
					Invoking <strong>##class(%SYS.OAuth2.AccessToken).GetIntrospection( ... )</strong> at #($ZDateTime($H,3))# ...
				>

			#Dim tDynamicObject As %DynamicAbstractObject
			Set tStatus = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(tOAuth2AppName, tAccessToken, .tDynamicObject)
			If ($$$ISERR(tStatus)) {
				Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
				Return $$$OK
			}

			&html<
				<br>Done
				<br>&nbsp; &nbsp; doing a pause of 0,1 seconds to ease logging>
			Hang 0.1
			&html<
				<br>&nbsp; &nbsp; here is the (formatted contents of the) tDynamicObject returned by the previous call:
				<br><textarea id="token" rows="14" cols="60">>
				#Dim tJSONString As %String
				Set tStatus = ##class(%JSON.Formatter).%New().FormatToString(tDynamicObject, .tJSONString)
				If ($$$ISERR(tStatus)) {
					Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
					Return $$$OK
				}
				Write tJSONString
			&html<</textarea></p>>
		}

		/********************************************************************************
		Access FHIR server
		*/

		// Prepare tHttpRequest

		&html<
			<h3>Building tHttpRequest (%Net.HttpRequest) to invoke FHIR interaction</h3>>

		#Dim tHttpRequest As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()

		#Dim tResourcesUrl As %String
		Set tResourcesUrl = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _
							 ..#RESOURCESPATH _ "/Patient"
		Set tStatus = tHttpRequest.SetHeader("Accept", "application/fhir+json")
		&html<
			<p>tHttpRequest.ReturnHeaders() returns: 
			<pre>#(tHttpRequest.ReturnHeaders())#</pre></p>>

		// Add Access Token

		&html<
			<p>
				Invoking <strong>##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "header", ... )</strong> at #($ZDateTime($H,3))# ...
			>

		Set tStatus = ##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "header", ..#CLIENTSSLCONFIGNAME, tOAuth2AppName)
		If ($$$ISERR(tStatus)) {
			&html<<br>the call returnd error status = #(##class(%SYSTEM.OBJ).DisplayError(tStatus))#</p>>
			Return $$$OK  
		}
		&html<<br>Done!
			<br>&nbsp; &nbsp; the headers now (tHttpRequest.ReturnHeaders()):>
		&html<<pre>#(tHttpRequest.ReturnHeaders())#</pre><br>
			</p>>

		// Do FHIR Interaction

		&html<
			<h3>Invoking FHIR interaction</h3>>

		&html<
			<p>
				Invoing #(tResourcesUrl)# using <strong>tHttpRequest.Get(#(tResourcesUrl)#)</strong> at #($ZDateTime($H,3))# ...
			>

		Set tStatus = tHttpRequest.Get(tResourcesUrl)

		If ($$$ISERR(tStatus)) {
			&html<<br>the call returnd error status = #(##class(%SYSTEM.OBJ).DisplayError(tStatus))#</p>>
			Return $$$OK  
		}
		&html<<br>The call returned: #(tHttpRequest.HttpResponse.StatusLine)#
		<br>&nbsp; &nbsp; here is what was returned:
		<br><textarea id="FHIRresponse" rows="14" cols="60">>
		Write "tHttpRequest.ResponseStream = " _ tHttpRequest.ResponseStream, !
		Write "tHttpRequest.HttpResponse.StatusLine = " _ tHttpRequest.HttpResponse.StatusLine, !
		Write "tHttpRequest.HttpResponse = " _ tHttpRequest.HttpResponse, !
		Write "tHttpRequest.HttpResponse.Data = " _ tHttpRequest.HttpResponse.Data, !
		Write:$IsObject(tHttpRequest.HttpResponse.Data) "tHttpRequest.HttpResponse.Data.Size = " _ tHttpRequest.HttpResponse.Data.Size, !

		Write "The (JSON formatted) response body:", !
		
		#Dim tResponseBody As %String = tHttpRequest.HttpResponse.Data
		If ($IsObject(tResponseBody)) {
			Set tResponseBody = tHttpRequest.HttpResponse.Data.Read()
		}
		If ($Length(tResponseBody)) {
			Set tJSONString = ""
			Set tStatus = ##class(%JSON.Formatter).%New().FormatToString(tResponseBody, .tJSONString)
			If ($$$ISERR(tStatus)) {
				Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
				Return $$$OK
			}
		}
		Write tJSONString
		&html<</textarea></p>>
	}
	Catch tException {
		Write "tException.DisplayString() = " _ tException.DisplayString(), !
	}
	Return $$$OK
}

ClassMethod CheckCreateClientConfiguration(pOAuth2AppName As %String, pClientType As %String)
{
	&html<
		<h3>Ensuring that we have a client configuration with name #(pOAuth2AppName)#</h3>
		<p>
			Invoking <strong>..CheckCreateClientConfiguration( ... )</strong> at #($ZDateTime($H,3))# ...
		>

	New $Namespace
	Set $Namespace = "%SYS"

	Do ##class(FHIRSMARTEx.Setup.OAuth2Clients).CheckCreateClientConfigurationHtml(pOAuth2AppName, "confidential")
}

/// Checks it this client is currently authorized or not
ClassMethod IsAuthorized(pOAuth2AppName As %String, Output pAccessToken As %String, Output pIdToken As %String, pResponseProperties As %String) As %Boolean
{
	&html<
		<h3>Testing if we are already authenticated & authorized</h3>
		<p>
			Invoking <strong>##class(%SYS.OAuth2.AccessToken).IsAuthorized( ... )</strong> at #($ZDateTime($H,3))# ...
		>

	#Dim tResponseProperties
	#Dim tError As %OAuth2.Error
	#Dim tIsAuthorized As %Boolean = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(pOAuth2AppName,,..Scope(), .pAccessToken, .pIdToken, .pResponseProperties, .tError)
	If (tIsAuthorized) {
		&html<
			<br>This client is authorized>
	}
	Else {
		&html<
			<br>This client is not authorized
			<br>&nbsp; &nbsp; tError = #(tError)#
		>
		If ($IsObject(tError)) {
			&html<<br>&nbsp; &nbsp; Error = #(tError.Error)#>
			&html<<br>&nbsp; &nbsp; ErrorDescription = #(tError.ErrorDescription)#>
			&html<<br>&nbsp; &nbsp; ErrorUri = #(tError.ErrorUri)#>
			&html<<br>&nbsp; &nbsp; $Data(pResponseProperties) = #($Data(pResponseProperties))#>
		}
		Else {
			&html<<br>&nbsp; &nbsp; nothing returned as argument error>
			&html<<br>&nbsp; &nbsp; $Data(pResponseProperties) = #($Data(pResponseProperties))#>
		}
		&html<</p>>	
	}

	Return tIsAuthorized
}

}
