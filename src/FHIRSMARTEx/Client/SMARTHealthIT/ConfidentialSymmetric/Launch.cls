/// This does not work ...
/// 
/// <p>A client for testing client-confidential-symmetric authentication mechanism
/// https://build.fhir.org/ig/HL7/smart-app-launch/client-confidential-symmetric.html</p>
/// 
/// <p>Documentation of the JS library.
/// 	SMART: http://docs.smarthealthit.org/client-js/api.html</p>
/// 
/// <p>To invoke this, provide iss and optionally launch: e.g.:
/// 	https://fi01.intersystems.co.uk/csp/healthshare/smart/SMARTFHIR.Test.SMARTHealthIT.ConfidentialPublic.Launch.cls?iss=https://fi01.intersystems.co.uk/sfs01/fhir/r4
/// </p>
Class FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Launch Extends %CSP.Page
{

// Name of the client descriptor

Parameter OAUTH2APPNAME = "SMARTHealthITConfidentialSymmetric";

ClassMethod OnPage() As %Status
{
	#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))
	#Dim tRedirectPage As %String = $Replace($Piece(tThisPage, "?", 1), "Launch", "Index")

	If (0) {
		&html<<html><body>>
		&html<<p>tThisPage = #(tThisPage)#</p>>
		&html<<p>tRedirectPage = #(tRedirectPage)#</p>>
		&html<</body></html>>
		Return $$$OK
	}

	/*
	 * Find the clientId and clientSecret from the Server's client descriptors
	 *
	 */

 //&html<<p>start</p>>
 	#Dim tNamespace = $Namespace
 //&html<<p>tNamespace = #(tNamespace)#</p>>
	Zn "%SYS"
 //&html<<p>start2</p>>

	#Dim tClient As OAuth2.Server.Client = $$$NULLOREF
	#Dim tOAuth2AppName As %String = ..#OAUTH2APPNAME
	#Dim tClientId As %String = ""
	&Sql(Select Id Into :tClientId From OAuth2_Server.Client Where Name = :tOAuth2AppName)
	If (SQLCODE < 0) {
		&html<<html><body>#(%msg)#</body></html>>
		Return $$$OK
	}
	If (SQLCODE = 0) Set tClient = ##class(OAuth2.Server.Client).%OpenId(tClientId,,.tStatus)
	If ('$IsObject(tClient)) {
		&html<<html><body>OAuth client description with name #(tOAuth2AppName)# not found</body></html>>
		Return $$$OK
	}
	Zn tNamespace

 //&html<<p>tClient = #(tClient)#</p>>

	/*
	 * This is from https://docs.smarthealthit.org/tutorials/javascript/
	 *
	 */

	&html<

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Launch My APP</title>
        <script src="https://cdn.jsdelivr.net/npm/fhirclient/build/fhir-client.js"></script>
    </head>
    <body>
        <script>
            FHIR.oauth2.authorize({

              // The client_id that you should have obtained after registering a client at
              // the EHR.
              clientId: "#(tClient.ClientId)#",
              clientSecret: "#(tClient.ClientSecret)#",

              // The scopes that you request from the EHR. In this case we want to:
              // launch            - Get the launch context
              // openid & fhirUser - Get the current user
              // patient/*.read    - Read patient data
              scope: "launch/patient openid fhirUser patient/*.read",

              // Typically, if your redirectUri points to the root of the current directory
              // (where the launchUri is), you can omit this option because the default value is
              // ".". However, some servers do not support directory indexes so "." and "./"
              // will not automatically map to the "index.html" file in that directory.
              redirectUri: "#(tRedirectPage)#"
            });
        </script>
    </body>
</html>

>
	Return $$$OK
}

}
