Class FHIRSMARTEx.Util.CSP.ISCLOG.Simple Extends FHIRSMARTEx.Util.CSP.Common
{

ClassMethod WriteBody(pBaseURL As %String)
{
 	#Dim tStatus As %Status = $$$OK
	#Dim tUrl As %String

	New $Namespace
	Set $Namespace = "%SYS"

	&html<<h3>$Namespace = #($Namespace)#</h3>> 

	&html<<pre>>

	// First node
	Set tNode = $QUERY(^ISCLOG("Data", ""))
	While tNode '= "" {
		#Dim tSubscripts As %String = $Piece($Piece(tNode, ",", 2, *), ")", 1)

		//Write tSubscripts
		If ($Length(tSubscripts, ",") = 1) {
			Write $Piece(tSubscripts, ",", 1) _ " "
			//Write @tNode
			//Write $List(@tNode, 1, *)
			For i=2:1:$ListLength(@tNode) 
			{
				//Write "ListItem0"_i _ ", "
				Write $List(@tNode, i) _ ", "
			}
			Write $List(@tNode, 1)
		}
		Else {
			For i=0:1:$Length(tSubscripts, ",") {
				Write "  "
			}
			If ($Length(tSubscripts, ",") > 2) {
				Write $Piece(tSubscripts, ",", 3, *) _ " = "
			}
			//Write @tNode
			Write ..Escape(@tNode)
		}
		Write !

		// Next node
		Set tNode = $QUERY(@tNode)
	}

	&html<</pre>>
}

ClassMethod Escape(pString As %String) As %String
{
	#Dim tString = $Replace(pString, $Char(13,10), "_$c(13,10)_")
	Return tString
}

}
