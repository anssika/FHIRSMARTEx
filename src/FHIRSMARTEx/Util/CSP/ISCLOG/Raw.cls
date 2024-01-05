Class FHIRSMARTEx.Util.CSP.ISCLOG.Raw Extends FHIRSMARTEx.Util.CSP.Common
{

ClassMethod WriteBody(pBaseURL As %String)
{
 	#Dim tStatus As %Status = $$$OK
	#Dim tUrl As %String

	New $Namespace
	Set $Namespace = "%SYS"

	&html<<h3>$Namespace = #($Namespace)#</h3>> 

	&html<<pre>>
	ZWrite ^ISCLOG
	&html<</pre>>
}

}
