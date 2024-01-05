Class FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.Client Extends %CSP.Page
{

// Name of the client configuration

Parameter OAUTH2APPNAME = "IRISConfidentialSymmetric";

Parameter CLIENTSSLCONFIGNAME = "client";

Parameter RESOURCESPATH = "/fhir/r4";

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException
	#Dim tKey As %String

	#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))

	&html<<html><head></head><body>>

	// Test if we are already authenticated & authorized? 

	&html<<h2>Testing if we are already authenticated & authorized</h2>>

	#Dim tAccessToken, tIdToken As %String
	#Dim tResponseProperties
	#Dim tError As %OAuth2.Error
	#Dim tIsAuthorized As %Boolean = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,..Scope(), .tAccessToken, .tIdToken,.tResponseProperties,.tError)

	If ('tIsAuthorized) {

	// NOT authorized
	// 
	// Do authenticate & authorise

		&html<<h2>No - we are not authorized</h2>>
		If ($IsObject(tError)) {
			&html<<p> Error = #(tError.Error)#<br>>
			&html<ErrorDescription = #(tError.ErrorDescription)#<br>>
			&html<ErrorUri = #(tError.ErrorUri)#<br>>
			&html<$Data(tResponseProperties) = #($Data(tResponseProperties))#<br></p>>
		}
		Else {
			&html<<p>No error returned<br>>
			&html<$Data(tResponseProperties) = #($Data(tResponseProperties))#</p>>
		}

		&html<<h2>Authenticate and Authorise</h2>>

		#Dim tProperties As %String
		Set tProperties("aud") = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ ..#RESOURCESPATH
		#Dim tUrl = ##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(..#OAUTH2APPNAME, ..Scope(),
													tThisPage,.tProperties,.tIsAuthorized,.tStatus)
		If ($$$ISERR(tStatus)) {
				&html<<br>Call of ##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint( ... ) returned an error:<br>>
				Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
				&html<</p>>
				Return $$$OK  
		}

		&html<<p>Please select the link below to authenticate and authorise with scope: #(..Scope())#</p>> 

		&html<<p><a href='#(tUrl)#'>#(tUrl)#</a></p>>

		Return $$$OK  
	}


	// Authorized
	// 

	Try {
		&html<<h3>Yes - we are  authorized</h3>>
		&html<<p>tAccessToken = #(tAccessToken)#<br>>
		&html<tIdToken = #(tIdToken)#<br>>
		&html<$Data(tResponseProperties) = #($Data(tResponseProperties))#<br></p>>
		Set tKey = $Order(tResponseProperties(""))
		Write "<table>", !
		While (tKey '= "") {
			Write "<tr><td>tResponseProperties(" _ tKey _ ") = </td><td>" _ tResponseProperties(tKey) _ "</td></tr>", !
			Set tKey = $Order(tResponseProperties(tKey))
		}
		Write "</table>"

		#Dim tDynamicObject As %DynamicAbstractObject
		Set tStatus = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(..#OAUTH2APPNAME, tAccessToken, .tDynamicObject)
		If ($$$ISERR(tStatus)) {
			Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
			Return $$$OK
		}
		Write "tDynamicObject.%ToJSON() = " _ tDynamicObject.%ToJSON() _ "<br>"

		#Dim tJSONString As %String
		Set tStatus = ##class(%JSON.Formatter).%New().FormatToString(tDynamicObject, .tJSONString)
		If ($$$ISERR(tStatus)) {
			Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
			Return $$$OK
		}
		&html<tJSONString:<br><textarea id="tJSONString" rows="16" cols="60">#(tJSONString)#</textarea><br>>
		&html<tDynamicObject.scope = #(tDynamicObject.scope)#<br>>

		Write "</p>"
	}
	Catch tException {
		Write "tException.DisplayString() = " _ tException.DisplayString(), !
	}


	// Access the resources

	&html<<h2>Accessing the resources</h2>>

	Try {

		// Create the HTTP request for accessing the resources
		#Dim tHttpRequest As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()
		If (1) {
			//Set tStatus = tHttpRequest.SetHeader("AUTHORIZATION", "Basic " _ ##class(%SYSTEM.Encryption).Base64Encode("akauppi:sys"))
			//Set tStatus = tHttpRequest.SetHeader("AUTHORIZATION", "Basic " _ ##class(%SYSTEM.Encryption).Base64Encode("superuser:88=Yyteri"))
			//Set tStatus = ##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "query", ..#SSLCONFIG, ..#OAUTH2APPNAME)
			&html<<pre>tHttpRequest.ReturnHeaders() = #(tHttpRequest.ReturnHeaders())#</pre><br>>
			&html<Calling AddAccessToken<br>>
			Set tStatus = ##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest, "header", ..#CLIENTSSLCONFIGNAME, ..#OAUTH2APPNAME)
			If ($$$ISERR(tStatus)) {
				Write "<p> ERROR = " _ ##class(%SYSTEM.OBJ).DisplayError(tStatus) _ "</p>"
				Return $$$OK  
			}
			&html<<pre>tHttpRequest.ReturnHeaders() = #(tHttpRequest.ReturnHeaders())#</pre><br>>
		}
		Else {
			Set tHttpRequest.SSLConfiguration = "client"
		}

		// Access the resources
		Set tStatus = tHttpRequest.SetHeader("Accept", "application/fhir+json")
		If ($$$ISERR(tStatus)) {
			Write "<p> ERROR = " _ ##class(%SYSTEM.OBJ).DisplayError(tStatus) _ "</p>"
			Return $$$OK  
		}
		#Dim tResourcesURL As %String
		Set tResourcesURL = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _
							 ..#RESOURCESPATH _ "/Encounter"

		&html<<p>About to access #(tResourcesURL)#</p>>

		&html<<pre>tHttpRequest.ReturnHeaders() = #(tHttpRequest.ReturnHeaders())#</pre><br>>
		&html<<pre>tResourcesURL = #(tResourcesURL)#</pre><br>>
		Set tStatus = tHttpRequest.Get(tResourcesURL)

		&html<<p>#(tResourcesURL)# returned</p>>
		&html<<p>>
		&html<tStatus = #(tStatus)#<br>>
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		&html<tHttpRequest.HttpResponse.StatusLine = #(tHttpRequest.HttpResponse.StatusLine)#<br>>
		&html<tHttpRequest.ResponseStream = #(tHttpRequest.ResponseStream)#<br>>
		&html<tHttpRequest.HttpResponse = #(tHttpRequest.HttpResponse)#<br>>
		&html<tHttpRequest.HttpResponse.Data = #(tHttpRequest.HttpResponse.Data)#<br></p>>
		&html<tHttpRequest.HttpResponse.Data.Size = #(tHttpRequest.HttpResponse.Data.Size)#<br></p>>

		&html<<h3>The response body is:</h3>>

		&html<<p>>
		#Dim tResponseBody As %String = ""
		If ($IsObject(tHttpRequest.HttpResponse.Data)) {
			Set tResponseBody = tHttpRequest.HttpResponse.Data.Read()
		}
		Set tJSONString = ""
		Set tStatus = ##class(%JSON.Formatter).%New().FormatToString(tResponseBody, .tJSONString)
		If ($$$ISERR(tStatus)) {
			Write ##class(%SYSTEM.Status).GetErrorText(tStatus)
			Return $$$OK
		}
		&html<tResponseBody = #(tResponseBody)#<br>>
		&html<tResponseBody (JSON formatteds):<br><textarea id="tJSONString" rows="16" cols="90">#(tJSONString)#</textarea><br>>

		&html<</p>>
	}
	Catch tException {
		Write "tException.DisplayString() = " _ tException.DisplayString(), !
	}

	&html<</body></html>>

	Return $$$OK
}

ClassMethod Scope() As %String
{
	Return "user/*.*"
	Return "system/*.*"
	Return "openid patient/*.* launch/patient/2"
	//Return "openid patient/*.* launch/patient/*"
	//Return "openid patient/*.*"
	//Return "openid user/*.*"
}

}
