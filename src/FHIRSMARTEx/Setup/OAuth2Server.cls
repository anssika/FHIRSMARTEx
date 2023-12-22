Class FHIRSMARTEx.Setup.OAuth2Server Extends FHIRSMARTEx.Setup.OAuth2Common
{

ClassMethod Setup()
{
	New $Namespace
	Set $Namespace = "%SYS"

	// Create and configure the server
	Do ..CreateUpdateOAuth2Server()

	#Dim tRedirectURL As %String
	Set tRedirectURL = "https://" _ ..#ISSUERENDPOINTHOST _ ":" _ ..#ISSUERENDPOINTPORT _ "/csp/sys/FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialPublic.Index.cls"
	Do ..CreateUpdateAClientDescription("SMARTHealthITConfidentialPublic", "confidential", "SMARTHealthIT ConfidentialPublic Client", tRedirectURL)
}

/// OAuth2 server:
ClassMethod CreateUpdateOAuth2Server()
{
	Set ^Log($Increment(^Log)) = $ZDateTime($H, 3) _ ": starting CreateOAuth2Server of FHIRSMARTEx.Install ..."

	#Dim tStatus As %Status = $$$OK

	#Dim tConfiguration As OAuth2.Server.Configuration
	Set tConfiguration = ##class(OAuth2.Server.Configuration).Open(.tStatus)
	If ('$IsObject(tConfiguration)) {
		Write " Creating a new OAuth 2 authorization server configuration ...", !
		Set tConfiguration = ##class(OAuth2.Server.Configuration).%New()
	}
	Else {
		Write " Found OAuth 2 authorization server configuration - updating it ...", !
	}

	Set tConfiguration.Description = "IRIS Auth2 Server"
	Set tConfiguration.IssuerEndpoint.Host = ..#ISSUERENDPOINTHOST
	Set tConfiguration.IssuerEndpoint.Port = ..#ISSUERENDPOINTPORT
	Set tConfiguration.SSLConfiguration = ..#CLIENTSSLCONFIGNAME

	// There at least on scope just need to be 
	Do tConfiguration.SupportedScopes.SetAt("Scope 1 description", "scope1")
	Set tConfiguration.AllowUnsupportedScope = 1
	Set tConfiguration.DefaultScope = "openid"

	Set tConfiguration.AccessTokenInterval = 300	// 3600
	Set tConfiguration.SessionInterval = 300		// 86400

	Set tConfiguration.CustomizationNamespace = "%SYS"
	Set tConfiguration.CustomizationRoles = "%DB_IRISSYS,%Manager"

	Set tStatus = tConfiguration.Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	Set ^Log($Increment(^Log)) = $ZDateTime($H, 3) _ ": done with CreateOAuth2Server of FHIRSMARTEx.Install"
}

/// OAuth2 server:
/// A client descriptor for the OAuth2 server
ClassMethod CreateUpdateAClientDescription(pOAuth2AppName As %String, pClientType As %String, pOAuth2AppDescription As %String, pRedirectURL As %String = "")
{
	#Dim tStatus As %Status = $$$OK

	#Dim tClient As OAuth2.Server.Client = $$$NULLOREF
	#Dim tClientId As %Integer = 0
	&Sql(Select Id Into :tClientId From OAuth2_Server.Client Where Name = :pOAuth2AppName)
	If (SQLCODE < 0) Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	If (SQLCODE = 0) Set tClient = ##class(OAuth2.Server.Client).%OpenId(tClientId,,.tStatus)
	If ('$IsObject(tClient)) {
		Write " Creating new client description " _ pOAuth2AppName _ " ...", !
		Set tClient = ##class(OAuth2.Server.Client).%New()
		Set tClient.Name = pOAuth2AppName
	}
	Else {
		Write " Found existing client description - updating it ...", !
	}

	Set tClient.Description = pOAuth2AppDescription
	Set tClient.ClientType = pClientType
	While (tClient.RedirectURL.Count()) {
		Do tClient.RedirectURL.RemoveAt(1)
	}

	// No redirectURL for a resource server
	If (pRedirectURL '= "") Do tClient.RedirectURL.Insert(pRedirectURL)

	If (pClientType = "confidential") {
		Set tClient.Metadata."grant_types" = $lb("authorization_code","refresh_token")
		Set tClient.Metadata."response_types" = $lb("code")
		Set tClient.Metadata."token_endpoint_auth_method" = "client_secret_basic"
	}

	Set tStatus = tClient.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
}

ClassMethod Test()
{
	#Dim tClient As OAuth2.Server.Client = $$$NULLOREF
	#Dim tOAuth2AppName As %String = "SMARTHealthITConfidentialPublic"
	#Dim tClientId As %String = ""
	&Sql(Select Id Into :tClientId From OAuth2_Server.Client Where Name = :tOAuth2AppName)
	If (SQLCODE < 0) Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	If (SQLCODE = 0) Set tClient = ##class(OAuth2.Server.Client).%OpenId(tClientId,,.tStatus)
	If ('$IsObject(tClient)) {
		Write "OAuth client description with name " _ tOAuth2AppName _ " not found", !
		Return
	}

	Write "tClient = " _ tClient, !
	Write "tClient.Metadata = " _ tClient.Metadata _ " = ", !
	ZWrite tClient.Metadata
}

/*

/// OAuth2 server:
/// Client descriptors for the OAuth2 server
ClassMethod CreateUpdateClientDescriptors()
{
	// DO we need a redirect URL for resource server?
	//Do ..CreateUpdateAClientDescription("/fhir/r4", "resource", "FHIR resource server /fhir/r4", "https://fi01.intersystems.co.uk/csp/sys/oauth2/OAuth2.Response.cls")
	//Do ..CreateUpdateAClientDescription("/fhir/r4", "resource", "FHIR resource server /fhir/r4")
	#Dim tRedirectURL As %String
	Set tRedirectURL = "https://" _ ..#ISSUERENDPOINTHOST _ ":" _ ..#ISSUERENDPOINTPORT _ "/csp/sys/FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialPublic.Index.cls"
	//Do ..CreateUpdateAClientDescription("SMARTHealthITCP", "confidential", "SMARTHealthIT ConfidentialPublic Client", tRedirectURL)
}
*/
}
