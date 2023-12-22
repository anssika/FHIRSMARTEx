Class FHIRSMARTEx.Setup.OAuth2Common
{

Parameter CLIENTSSLCONFIGNAME = "client";

Parameter ISSUERENDPOINTHOST = "wg-fhir";

/// If the port is 443, you can leave the port empty
/// Parameter ISSUERENDPOINTPORT = 443;
Parameter ISSUERENDPOINTPORT = 58143;

ClassMethod GetIssuerEndpoint() As %String
{
	#Dim tIssuerEndpoint As %String = "https://" _ ..#ISSUERENDPOINTHOST
	If (..#ISSUERENDPOINTPORT '= "") Set tIssuerEndpoint = tIssuerEndpoint _ ":" _ ..#ISSUERENDPOINTPORT
	Set tIssuerEndpoint = tIssuerEndpoint _ "/oauth2"
	Return tIssuerEndpoint
}

}
