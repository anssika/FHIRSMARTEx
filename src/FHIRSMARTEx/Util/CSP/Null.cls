Class FHIRSMARTEx.Util.CSP.Null Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	Return $$$OK
}

ClassMethod Test()
{
	#Dim tStatus As %Status = $$$OK

	#Dim tHttpRequest As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()
	Set tHttpRequest.Https = 1
	Set tHttpRequest.SSLConfiguration = "client"
	Set tHttpRequest.Server = "wg-fhir"
	Set tHttpRequest.Port = 58143

	Set tStatus = tHttpRequest.Get("/csp/healthshare/fhir/FHIRSMARTEx.Util.CSP.Null.cls")
	If ($$$ISERR(tStatus)) {
		Do ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Return
	}

	Do tHttpRequest.HttpResponse.OutputToDevice()
}

}
