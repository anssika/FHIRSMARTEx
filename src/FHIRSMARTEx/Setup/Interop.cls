Class FHIRSMARTEx.Setup.Interop
{

Parameter INTEROPPRODUCTION = "FHIRPKG.FoundationProduction";

ClassMethod Setup()
{
	New $Namespace
	Set $Namespace = "FHIR"

	Do ..ConfigureStartProduction()
}

ClassMethod ConfigureStartProduction()
{
	#Dim tStatus As %Status = $$$OK

	Write " Setting production " _ ..#INTEROPPRODUCTION _ " to autostart ...", !
	Set tStatus = ##class(Ens.Director).SetAutoStart(..#INTEROPPRODUCTION, 10)

	Write " Checking if production " _ ..#INTEROPPRODUCTION _ " already ...", !
	If ('##class(Ens.Director).IsProductionRunning(..#INTEROPPRODUCTION)) {
		Write " Starting production " _ ..#INTEROPPRODUCTION _ " ...", !
		Set tStatus = ##class(Ens.Director).StartProduction(..#INTEROPPRODUCTION)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
}

}
