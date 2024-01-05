Class FHIRSMARTEx.Util.CSP.Common Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException
	#Dim tKey As %String

	Try {

		#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))
		#Dim tBaseUrl As %String = $Piece(tThisPage, "/", 1, *-1)

		Do ..WriteLink(tBaseUrl _ "/FHIRSMARTEx.Util.CSP.Home.cls")

		Do ..WriteBody(tBaseUrl)
	}
	Catch tException {
		Write "tException.DisplayString() = " _ tException.DisplayString(), !
	}

	Return $$$OK
}

ClassMethod WriteBody(pBaseUrl As %String)
{
}

ClassMethod WriteLink(pUrl As %String, pLink As %String = "", pHtmlAfterLink As %String = "")
{
	if (pLink = "") Set pLink = pUrl
	&html<<a href='#(pUrl)#'>#(pLink)#</a>#(pHtmlAfterLink)#>
}

}
