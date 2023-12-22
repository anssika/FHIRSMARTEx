Class FHIRSMARTEx.Client.SMARTHealthIT.Start Extends %CSP.Page
{

Parameter HOSTNAME = "wg-fhir";

Parameter SSLPORT = 58143;

// The client executes on the browser

Parameter ISS = "https://wg-fhir:58143/fhir/r4";

Parameter LAUNCH = "MyLaunchId";

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))

	&html<<html><head></head><body>>

	&html<<h2>Invoke Launch URL</h2>>

	#Dim tNextPage As %String = $Replace(tThisPage, "Start", "ConfidentialPublic.Launch") _ "?iss=" _ ..#ISS _ "&launch=" _ ..#LAUNCH
	
	&html<<p>Please select one of the links below:</p>>
	&html<<p><a href='#(tNextPage)#'>#(tNextPage)#</a></p>>

	Set tNextPage = "https://examples.smarthealthit.org/growth-chart-app/launch.html" _ "?iss=" _ ..#ISS _ "&launch=" _ ..#LAUNCH
	&html<<p><a href='#(tNextPage)#'>#(tNextPage)#</a></p>>

	If (($Get(%request.CgiEnvs("REQUEST_SCHEME")) '= "https") ||
		($Find($Get(%request.CgiEnvs("SERVER_NAME")), "localhost"))) {
		&html<<h2>... or go first to this page ...</h2>>

		#Dim tSSLPort As %String = ""
		If (..#SSLPORT '= 443) Set tSSLPort = ":" _ ..#SSLPORT
		Set tNextPage = "https://" _ $Replace($Get(%request.CgiEnvs("SERVER_NAME")), "localhost", ..#HOSTNAME) _
						tSSLPort _ $Get(%request.CgiEnvs("REQUEST_URI"))

		&html<<p>Please select the link below:</p>>
		&html<<p><a href='#(tNextPage)#'>#(tNextPage)#</a></p>>

	}

	&html<</body></html>>

	Return $$$OK
}

ClassMethod Scope() As %String
{
	Return "openid patient/*.* launch/patient/2"
	//Return "openid patient/*.* launch/patient/*"
	//Return "openid patient/*.*"
	//Return "openid user/*.*"
}

}
