Class FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV2 Extends (%CSP.Page, FHIRSMARTEx.Setup.OAuth2Common)
{

/// Name of the client configuration
Parameter OAUTH2APPNAME = "IRISConfidentialSymmetricV2";

Parameter CLIENTSSLCONFIGNAME = "client";

Parameter RESOURCESPATH = "/fhir/r4";

ClassMethod Scope() As %String
{
	Return "launch user/*.*"
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
	#Dim tKey As %String


	#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))

	&html<<html><head></head><body>>

	// This call

	&html<
	<h3>About this page</h3>
	<p>
		tThisPage = #(tThisPage)#<br>
	</p>>


	/********************************************************************************

	Do we have a client configuration?
	If not, create one and register it with OAuth2 server

	*/

	&html<
		<h3>Ensuring that we have a client configuration with name #(..#OAUTH2APPNAME)#</h3>
		<p>
			Invoking <strong>..CheckCreateClientConfiguration( ... )</strong> at #($ZDateTime($H,3))# ...
		>

	Do ..CheckCreateClientConfiguration(..#OAUTH2APPNAME, "confidential")

	/********************************************************************************

	is this client authorized?

	*/

	&html<
		<h3>Testing if we are already authenticated & authorized</h3>
		<p>
			Invoking <strong>##class(%SYS.OAuth2.AccessToken).IsAuthorized( ... )</strong> at #($ZDateTime($H,3))# ...
		>

	#Dim tAccessToken, tIdToken As %String
	#Dim tResponseProperties
	#Dim tError As %OAuth2.Error
	#Dim tIsAuthorized As %Boolean = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,..Scope(), .tAccessToken, .tIdToken,.tResponseProperties,.tError)
	If (tIsAuthorized) {
		&html<
			<br>We are authorized
			//<br>&nbsp; &nbsp; doing a pause of 0,1 seconds to ease logging>
		Hang 0,1
	}
	Else {
		&html<
			<br>Not authorized - we need to authorize:
			<br>&nbsp; tError = #(tError)#
		>
		If ($IsObject(tError)) {
			&html<<br>&nbsp; &nbsp; Error = #(tError.Error)#>
			&html<<br>&nbsp; &nbsp; ErrorDescription = #(tError.ErrorDescription)#>
			&html<<br>&nbsp; &nbsp; ErrorUri = #(tError.ErrorUri)#>
			&html<<br>&nbsp; &nbsp; $Data(tResponseProperties) = #($Data(tResponseProperties))#>
		}
		Else {
			&html<<br>&nbsp; &nbsp; No error returned>
			&html<<br>&nbsp; &nbsp; $Data(tResponseProperties) = #($Data(tResponseProperties))#>
		}
		&html<</p>>		


		/********************************************************************************
		Create a link for starting authorisation
		*/

		&html<
			<h3>Getting authorisation endpoint url</h3>
			<p>
			Invoking <strong>##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(...)</strong> at #($ZDateTime($H,3))# ...>

		#Dim tProperties As %String
		Set tProperties("aud") = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ ..#RESOURCESPATH
		#Dim tUrl = ##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(..#OAUTH2APPNAME, ..Scope(),
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
	

	/********************************************************************************

	This client _IS_ authorized

	*/

	Try {
		&html<
			<h3>Se, we are authorized</h3>>

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
			Set tStatus = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(..#OAUTH2APPNAME, tAccessToken, .tDynamicObject)
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
			<p><pre>tHttpRequest.ReturnHeaders() = #(tHttpRequest.ReturnHeaders())#</pre></p>>

		// Add Access Token

		&html<
			<p>
				Invoking <strong>##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "header", ... )</strong> at #($ZDateTime($H,3))# ...
			>

		Set tStatus = ##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "header", ..#CLIENTSSLCONFIGNAME, ..#OAUTH2APPNAME)
		If ($$$ISERR(tStatus)) {
			&html<<br>the call returnd error status = #(##class(%SYSTEM.OBJ).DisplayError(tStatus))#</p>>
			Return $$$OK  
		}
		&html<<br>Done!
			<br>&nbsp; &nbsp; the headers now:>
		&html<<pre>tHttpRequest.ReturnHeaders() = #(tHttpRequest.ReturnHeaders())#</pre><br>
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

ClassMethod CheckCreateClientConfiguration(pOAuth2AppName As %String = {..#OAUTH2APPNAME}, pClientType As %String)
{
	New $Namespace
	Set $Namespace = "%SYS"

	Do ##class(FHIRSMARTEx.Setup.OAuth2Clients).CheckCreateClientConfigurationHtml(pOAuth2AppName, "confidential")
}

}
