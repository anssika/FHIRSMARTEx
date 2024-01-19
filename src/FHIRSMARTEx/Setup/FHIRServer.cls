Class FHIRSMARTEx.Setup.FHIRServer
{

ClassMethod Setup()
{
	New $Namespace
	Set $Namespace = "FHIR"

	Do ..CreateUpdateFHIRServer()
}

ClassMethod CreateUpdateFHIRServer()
{
	#Dim tStatus As %Status = $$$OK

	// Requirements of a namespace for a FHIR server
	Do ##class(HS.FHIRServer.Installer).InstallNamespace()

	// Properties of the FHIR server
	#Dim tAppKey As %String = "/fhir/r4"
	#Dim tStrategyClass As %String = "FHIRSMARTEx.FHIRServer.Storage.Json.InteractionsStrategy"
	#Dim tOAuth2ClientName As %String = "/fhir/r4"

	// Local profile - search parameters
	//do ##class(HS.FHIRMeta.Load.NpmLoader).importPackages("/home/irisowner/irisdev/MyFhirServer-searchparameters@0.0.1")

	// Install an instance of a FHIR Service into the current namespace
	If '##class(HS.FHIRServer.ServiceAdmin).EndpointExists(tAppKey)
	{
		//Set packageList = $ListBuild("hl7.fhir.r4.core@4.0.1", "MyFhirServer-searchparameters@0.0.1")
		Set tPackageList = $ListBuild("hl7.fhir.r4.core@4.0.1")
		Do ##class(HS.FHIRServer.Installer).InstallInstance(tAppKey, tStrategyClass, tPackageList)

		// Enable logging (see https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=HXFHIR_server_debugMaintain)
		//Set ^FSLogChannel("all") = 1
		//Set ^HS.FHIRServer("dev") = 1 // enable new tile!
		// You can now view the ^FSLog using 
		// http://localhost:32783/csp/healthshare/fhir/GJ.Log.cls
    }

	#Dim tStrategy As HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(tAppKey)
	#Dim tConfig As HS.FHIRServer.API.ConfigData = tStrategy.GetServiceConfigData()
	//Set tConfig.DebugMode = 4
	//Do tStrategy.SaveServiceConfigData(tConfig)
	//Set tConfig.FHIRMetadataSet = "launch-ehr,client-confidential-symmetric,client-public,context-ehr-patient,permission-patient"
	Do ##class(HS.FHIRServer.Installer).UpdateInstance(tAppKey, tConfig.AsJSONString(), 1, "", tOAuth2ClientName)

	#Dim tInstanceId As %String = ##class(HS.FHIRServer.ServiceAdmin).GetInstanceIdForEndpoint(tAppKey)
	// An instance of HS.FHIRServer.RepoInstance
	#Dim tServiceInstance as HS.FHIRServer.ServiceInstance= ##class(HS.FHIRServer.ServiceInstance).GetById(tInstanceId)
	#Dim tStrategyConfig As %DynamicObject = {}.%FromJSON(tServiceInstance.strategyConfigData)
	Set tStrategyConfig."smart_capabilities" = "launch-ehr,client-confidential-symmetric,client-public,context-ehr-patient,permission-patient"
	//Set tStrategyConfig."silence_index_errors" = false
	Set tServiceInstance.strategyConfigData = tStrategyConfig.%ToJSON()
	Set tStatus = tServiceInstance.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	//#Dim tRESTCSPConfig As HS.Util.RESTCSPConfig = ##class(HS.Util.RESTCSPConfig).URLIndexOpen($$$AppKeyFromApp(%request.AppMatch))
	#Dim tRESTCSPConfig As HS.Util.RESTCSPConfig = ##class(HS.Util.RESTCSPConfig).URLIndexOpen(tAppKey)
	Set tRESTCSPConfig.ServiceConfigName = "From_FHIR_API"
	Set tStatus = tRESTCSPConfig.%Save()
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	Set ^Log($Increment(^Log)) = $ZDateTime($H, 3) _ ": done with CreateFHIRServer of FHIRSMARTEx.Install"
}

ClassMethod Test()
{
	#Dim tAppKey As %String = "/fhir/r4"
	#Dim tStrategy As HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(tAppKey)
	#Dim tConfig As HS.FHIRServer.API.ConfigData = tStrategy.GetServiceConfigData()
	Write "tConfig = " _ tConfig _ " = ", !
	ZWrite tConfig
	#Dim tConfigString As %String = tConfig.AsJSONString()
	Write "tConfigString = " _ tConfigString, !

	#Dim tInstanceId As %String = ##class(HS.FHIRServer.ServiceAdmin).GetInstanceIdForEndpoint(tAppKey)
	Write "tInstanceId = " _ tInstanceId, !

	#Dim tServiceInstance as HS.FHIRServer.ServiceInstance= ##class(HS.FHIRServer.ServiceInstance).GetById(tInstanceId)
	Write "tServiceInstance " _ tServiceInstance _ " = ", !

	ZWrite tServiceInstance

	#Dim tStrategyConfig As %DynamicObject = {}.%FromJSON(tServiceInstance.strategyConfigData)
	Write "tServiceInstance.strategyConfigData = " _ tServiceInstance.strategyConfigData, !
	Set tStrategyConfig."smart_capabilities" = "launch-ehr,client-confidential-symmetric,client-public,context-ehr-patient,permission-patient"
	//Set tStrategyConfig."silence_index_errors" = false
	Set tServiceInstance.strategyConfigData = tStrategyConfig.%ToJSON()
	Write "tServiceInstance.strategyConfigData = " _ tServiceInstance.strategyConfigData, !
}

}
