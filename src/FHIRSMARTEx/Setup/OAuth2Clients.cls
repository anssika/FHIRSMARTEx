Class FHIRSMARTEx.Setup.OAuth2Clients Extends FHIRSMARTEx.Setup.OAuth2Common
{

ClassMethod Setup()
{
	New $Namespace
	Set $Namespace = "%SYS"

	// Create and configure the clients
	Do ..CreateUpdateServerDescription()

	// FHIR server and OAuth2 server have the same HOST and PORT
	Do ..CreateUpdateAClientConfiguration("/fhir/r4", "resource", ..#ISSUERENDPOINTHOST, ..#ISSUERENDPOINTPORT)
	Do ..CreateUpdateAClientConfiguration("IRISConfidentialSymmetric", "confidential", ..#ISSUERENDPOINTHOST, ..#ISSUERENDPOINTPORT)
	// The other client configurations for IRIS clients are created by the client
}

/// OAuth2 client:
/// A server description
ClassMethod CreateUpdateServerDescription() As %Status
{
	#Dim tStatus As %Status = $$$OK

	// Server Description

	#Dim tServerDefinition As OAuth2.ServerDefinition = $$$NULLOREF
	#Dim tServerDefinitionId As %Integer = 0
	#Dim tIssuerEndpoint As %String = ..GetIssuerEndpoint()
	&Sql(Select Id Into :tServerDefinitionId From OAuth2.ServerDefinition Where IssuerEndpoint = :tIssuerEndpoint)
	If (SQLCODE < 0) Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	If (SQLCODE = 0) Set tServerDefinition = ##class(OAuth2.ServerDefinition).Open(tServerDefinitionId, .tStatus)
	If ('$IsObject(tServerDefinition)) {
		Write " Creating a new client server description for clients ...", !
		Set tStatus = ##class(%SYS.OAuth2.Registration).Discover(tIssuerEndpoint, ..#CLIENTSSLCONFIGNAME, .tServerDefinition)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
	Set tStatus = tServerDefinition.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
}

/// OAuth2 client:
/// A client configuration (for a server description)
ClassMethod CreateUpdateAClientConfiguration(pOAuth2AppName As %String, pClientType As %String, pRedirectHost As %String, pRedirectPort As %String)
{
	#Dim tStatus As %Status = $$$OK

	// Find Server Description

	#Dim tServerDefinition As OAuth2.ServerDefinition = $$$NULLOREF
	#Dim tServerDefinitionId As %Integer = 0
	#Dim tIssuerEndpoint As %String = ..GetIssuerEndpoint()
	&Sql(Select Id Into :tServerDefinitionId From OAuth2.ServerDefinition Where IssuerEndpoint = :tIssuerEndpoint)
	If (SQLCODE < 0) Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	If (SQLCODE = 0) Set tServerDefinition = ##class(OAuth2.ServerDefinition).Open(tServerDefinitionId, .tStatus)
	If ('$IsObject(tServerDefinition)) {
		Set tStatus = $$$ERROR($$$GeneralError, "Client server definition with issuer endpoint " _ tIssuerEndpoint _ " not found")
		Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}

	// Create client configuration

	#Dim tClient As OAuth2.Client = ##class(OAuth2.Client).Open(pOAuth2AppName, .tStatus)
	If ('$IsObject(tClient)) {
		Write " Creating new client configuration " _ pOAuth2AppName _ " ...", !
		Set tClient = ##class(OAuth2.Client).%New()
		Set tClient.ApplicationName = pOAuth2AppName
	}
	Else {
		Write " Modifying client configuration " _ pOAuth2AppName _ " ...", !
	}

	Set tClient.ServerDefinition = tServerDefinition
	Set tClient.Metadata."client_name" = pOAuth2AppName
	Set tClient.ClientType = pClientType
	Set tClient.SSLConfiguration = ..#CLIENTSSLCONFIGNAME
	Set tClient.RedirectionEndpoint.Host = pRedirectHost
	Set tClient.RedirectionEndpoint.Port = pRedirectPort
	If ($ListLength(tClient.Metadata."grant_types") = 0) {
		Set tClient.Metadata."grant_types" = $ListBuild("authorization_code")
	}

	Set tStatus = tClient.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	If ((tClient.ClientId '= "") && (tClient.ClientSecret '= "")) {
		Write " The client looks like being already registered", !
		Write " --> Updating client registration ...", !
		Set tStatus = ##class(%SYS.OAuth2.Registration).UpdateClient(pOAuth2AppName)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
	Else {
		Write " Registering client ...", !
		Set tStatus = ##class(%SYS.OAuth2.Registration).RegisterClient(pOAuth2AppName)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
}

ClassMethod CheckCreateClientConfigurationHtml(pOAuth2AppName As %String, pClientType As %String)
{
	New $Namespace
	Set $Namespace = "%SYS"

	#Dim tRedirectHost As %String = ..#ISSUERENDPOINTHOST
	#Dim tRedirectPort As %String = ..#ISSUERENDPOINTPORT

	// Find Server Description

	&html<<br>&nbsp; &nbsp; looking for OAuth2 server description for #(..GetIssuerEndpoint())# ...>
	#Dim tServerDefinition As OAuth2.ServerDefinition = $$$NULLOREF
	#Dim tServerDefinitionId As %Integer = 0
	#Dim tIssuerEndpoint As %String = ..GetIssuerEndpoint()
	&Sql(Select Id Into :tServerDefinitionId From OAuth2.ServerDefinition Where IssuerEndpoint = :tIssuerEndpoint)
	If (SQLCODE < 0) Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	If (SQLCODE = 0) Set tServerDefinition = ##class(OAuth2.ServerDefinition).Open(tServerDefinitionId, .tStatus)
	If ('$IsObject(tServerDefinition)) {
		Set tStatus = $$$ERROR($$$GeneralError, "Client server definition with issuer endpoint " _ tIssuerEndpoint _ " not found")
		Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
	&html<<br>&nbsp; &nbsp; found>

	// Find update client configuration

	&html<<br>&nbsp; &nbsp; looking for client configuration with name #(pOAuth2AppName)# ...>
	#Dim tClient As OAuth2.Client = ##class(OAuth2.Client).Open(pOAuth2AppName, .tStatus)
	If ($IsObject(tClient)) {
		&html<<br>&nbsp; &nbsp; found. The Id of the client is #(tClient.%Id())#>
		//Return $$$OK
	}
	Else {
		&html<<br>&nbsp; &nbsp; not found, creating new configuration ...>
		Set tClient = ##class(OAuth2.Client).%New()
		Set tClient.ApplicationName = pOAuth2AppName
	}

	Set tClient.ServerDefinition = tServerDefinition
	Set tClient.Metadata."client_name" = pOAuth2AppName
	Set tClient.ClientType = pClientType
	Set tClient.SSLConfiguration = ..#CLIENTSSLCONFIGNAME
	Set tClient.RedirectionEndpoint.Host = tRedirectHost
	Set tClient.RedirectionEndpoint.Port = tRedirectPort
	If ($ListLength(tClient.Metadata."grant_types") = 0) {
		//Set tClient.Metadata."grant_types" = $ListBuild("authorization_code")
		//Set tClient.Metadata."grant_types" = $ListBuild("client_credentials")
		Set tClient.Metadata."grant_types" = $ListBuild("authorization_code","client_credentials")
	}

	&html<<br>&nbsp; &nbsp; saving configuration...>
	Set tStatus = tClient.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	&html<<br>&nbsp; &nbsp; done>

	/*
	&html<<br>tClient = #(tClient)#>
	&html<<br>tClient.ClientId = #(tClient.ClientId)#>
 	&html<<br>tClient.ClientSecret = #(tClient.ClientSecret)#>
	*/

	If ((tClient.ClientId '= "") && (tClient.ClientSecret '= "")) {
		&html<<br>&nbsp; &nbsp; the client looks like being already registered ...>
		&html<<br>&nbsp; &nbsp; updating client registration ...>
		Set tStatus = ##class(%SYS.OAuth2.Registration).UpdateClient(pOAuth2AppName)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		&html<<br>&nbsp; &nbsp; done>
	}
	Else {
		&html<<br>&nbsp; &nbsp; registering client ...>
		Set tStatus = ##class(%SYS.OAuth2.Registration).RegisterClient(pOAuth2AppName)
		If ($$$ISERR(tStatus)) {
			&html<<br>&nbsp; &nbsp; registration failed: <pre>#(##class(%SYSTEM.Status).GetErrorText(tStatus))#</pre>>
		}

		&html<<br>&nbsp; &nbsp; done>
	}
}

}
