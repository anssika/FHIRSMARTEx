Class FHIRSMARTEx.Util.CSP.Home Extends FHIRSMARTEx.Util.CSP.Common
{

ClassMethod WriteBody(pBaseUrl As %String)
{
 	#Dim tStatus As %Status = $$$OK
	#Dim tUrl As %String

	&html<<h3>SMART Clients</h3>> 
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?grantType=CR", "IRIS Confidential Symmetric Client (V4) using client credentials grant type", "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?grantType=AC", "IRIS Confidential Symmetric Client (V4) using authorization code grant type", "<br>")

	#Dim tISS As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ "/fhir/r4"
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Launch.cls?iss=" _ tISS,, "<br>")

	&html<<br>>
	&html<<h3>Old SMART Clients - May not work any longer</h3>> 
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV3.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV2.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.Client.cls",, "<br>")

	&html<<h3>^ISCLOG</h3>> 

	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Util.CSP.ISCLOG.Viewer.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Util.CSP.ISCLOG.Simple.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Util.CSP.ISCLOG.Raw.cls")
	//Set tUrl = pBaseURL _ "/FHIRSMARTEx.Util.CSP.ISCLOG.Raw.cls"
	//&html<<p><a href='#(tUrl)#'>#(tUrl)#</a></p>>
}

}
