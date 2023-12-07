Class FHIRSMARTEx.Setup
{

ClassMethod ConfigureInstancefhir(pNamespace As %String = "FHIR")
{
	Do ..CreateFHIRServer(pNamespace)
}

ClassMethod CreateFHIRServer(pNamespace As %String = "FHIR")
{
	Set ^Log($Increment(^Log)) = $ZDateTime($H, 3) _ ": starting CreateFHIRServer of FHIRSMARTEx.Install ..."

	#Dim tStatus As %Status = $$$OK

	New $namespace
    Set $namespace = pNamespace

    Set tAppKey = "/fhir/r4"

    // Requirements of a namespace for a FHIR server
    Do ##class(HS.FHIRServer.Installer).InstallNamespace()

	// Local profile - search parameters
    //do ##class(HS.FHIRMeta.Load.NpmLoader).importPackages("/home/irisowner/irisdev/MyFhirServer-searchparameters@0.0.1")

   // Install an instance of a FHIR Service into the current namespace
    If '##class(HS.FHIRServer.ServiceAdmin).EndpointExists(tAppKey)
    {
		//Set packageList = $ListBuild("hl7.fhir.r4.core@4.0.1", "MyFhirServer-searchparameters@0.0.1")
		Set tPackageList = $ListBuild("hl7.fhir.r4.core@4.0.1")
		Do ##class(HS.FHIRServer.Installer).InstallInstance(tAppKey, "HS.FHIRServer.Storage.Json.InteractionsStrategy", tPackageList)

		// Enable logging (see https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=HXFHIR_server_debugMaintain)
		//Set ^FSLogChannel("all") = 1
		//Set ^HS.FHIRServer("dev") = 1 // enable new tile!
		// You can now view the ^FSLog using 
		// http://localhost:32783/csp/healthshare/fhir/GJ.Log.cls
    }

    #Dim tStrategy As HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(tAppKey)
    #Dim tConfig As HS.FHIRServer.API.ConfigData = tStrategy.GetServiceConfigData()
    Set tConfig.DebugMode = 4
    Do tStrategy.SaveServiceConfigData(tConfig)

	Set ^Log($Increment(^Log)) = $ZDateTime($H, 3) _ ": done with CreateFHIRServer of FHIRSMARTEx.Install"
}

}
