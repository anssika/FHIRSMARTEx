Class FHIRSMARTEx.Util.CSP.ISCLOG.Viewer Extends FHIRSMARTEx.Util.CSP.Common
{

ClassMethod WriteBody(pBaseURL As %String)
{
 	#Dim tStatus As %Status = $$$OK

	// Url parameters
	Set tPurge = $Get(%request.Data("purge", 1), "")
	Set tLogAdd = $Get(%request.Data("addLogCategory", 1), "")
	Set tLogRemove = $Get(%request.Data("removeLogCategory", 1), "")
	Set tViewCategories = $Get(%request.Data("viewCategories", 1), "")

	#Dim tThisPage As %String = pBaseURL _ "/FHIRSMARTEx.Util.CSP.ISCLOG.Viewer.cls?viewCategories=" _ tViewCategories

	New $Namespace
	Set $Namespace = "%SYS"

	&html<<h3>$Namespace = #($Namespace)#</h3>> 

	// Purge all?

	If (tPurge) {
		Kill ^ISCLOG("Data")
		&html<<p>^ISLOG("Data") purged</p>>
		Do ..WriteLink(tThisPage, "Refresh")
	}
	Else {
		Do ..WriteLink(tThisPage _ "&purge=1", "purge ISCLOG(""Data"")")
	}

	// Log categories

	If (tLogAdd '= "") {
		Set ^%ISCLOG("Category", tLogAdd) = 5
		&html<<p>Started logging category #(tLogAdd)#</p>>
	}
	If (tLogRemove '= "") {
		Kill ^%ISCLOG("Category", tLogRemove)
		&html<<p>Stopped logging category #(tLogRemove)#</p>>
	}

	&html<<p>>
	#Dim tCategories As %String = "HSFHIR,HSFHIRServer,OAuth2,OAuth2Server,CSPServer,CSPRequest,CSPResponse,CSPSession,HttpRequest"
	For i=1:1:$Length(tCategories, ",") {
		If ($Get(^%ISCLOG("Category", $Piece(tCategories, ",", i)))) {
			Do ..WriteLink(tThisPage _ "&removeLogCategory=" _ $Piece(tCategories, ",", i), "Stop logging category " _ $Piece(tCategories, ",", i))
		}
		Else {
			Do ..WriteLink(tThisPage _ "&addLogCategory=" _ $Piece(tCategories, ",", i), "Start logging category " _ $Piece(tCategories, ",", i))
		}
		&html<<br>>
	}
	&html<</p>>

	&html<<pre>>
	ZWrite ^%ISCLOG
	&html<</pre>>

	// View categories
	If (tViewCategories = "") {
		&html<<p>Viewing all categories</p>>
	}
	Else {
		&html<<p>Viewing categories #(tViewCategories)#</p>>
	}

	// Write ^ISCLOG("Data"

	&html<<pre>>
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
