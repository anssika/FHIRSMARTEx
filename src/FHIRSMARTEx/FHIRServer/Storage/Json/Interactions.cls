Class FHIRSMARTEx.FHIRServer.Storage.Json.Interactions Extends HS.FHIRServer.Storage.Json.Interactions
{

Parameter OAuth2TokenHandlerClass As %String = "FHIRSMARTEx.FHIRServer.Util.OAuth2Token";

/// 1 = add trace message, 0 = do not add trace messages
Parameter DOTRACE = 1;

/// 1 = require SMART 2.0 scopes (one of cruds), 0 = do not require
Parameter SMART2 = 1;

/// Copied from ParseRequestInputs of HS.FHIRServer.Service because is private there
ClassMethod mapToKey(part As %String, num As %Integer) [ Private ]
{
	if num = 1 {
		if (part = "metadata") return "m"
		if (part = "*") return "*"
	}
	
	if part = "*" return "*"
	if ($Extract(part) = "$") return "$"
	return $Case(part,
		"": "-",
		"_history":"h",
		"_search":"s",
		"_validate":"v",
		:"+")
}

/// Copied from ParseRequestInputs of HS.FHIRServer.Service
Method SMART2PrivNeeded(pFHIRService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, Output pHandlerMethod As %String = "") As %Boolean
{
	#Dim tSMART2PrivNeeded as %String = "cruds"
	
	// Parse the Verb and Path according to the FHIR REST spec
	Set tUrl = pRequest.RequestPath
	Set tVerb = $SELECT(pRequest.RequestMethod ="HEAD":"GET", 1:pRequest.RequestMethod)

	If $Extract(tUrl)="/" Set tUrl = $Extract(tUrl, 2, *)
	If $Extract(tUrl, *)="/" Set tUrl = $Extract(tUrl, 1, *-1)
	Set pRequest.RequestPath = tUrl
	Set partCount = $Length(tUrl, "/")
	if partCount > 4 {
		return tSMART2PrivNeeded
	}
	Set key = ""
	Set parts = ""
	for ord=1:1:4 {
		Set part = $Piece(tUrl, "/", ord)
		Set $List(parts,*+1) = part
		// Now encode the part as a single character for later pattern matching.
		Set key = key _ ..mapToKey(part, ord)
	}
	
	if $D(pFHIRService.RestUrlMap(tVerb, key), epMeta) = 0 {
		$$$FSLog("Cannot Dispatch Url: "_tVerb_" "_tUrl_"("_key_")")
		return tSMART2PrivNeeded
	}
	Set pRequest.Interaction = $ListGet(epMeta,1)
	Set fields = $ListGet(epMeta,2)
	Set pHandlerMethod = $ListGet(epMeta,3)
	Set privilege = $ListGet(epMeta,4)

	Set tSMART2PrivNeeded = $Case(pHandlerMethod,
									"History":"r",
									"Metadata":"",
									"Search":"s",
									"Read":"r",
									"Operation":"rs",
									"Patch":"cud",
									"ConditionalPatch":"cud",
									"Batch":"cud",
									"Search":"s",
									"Operation":"cud",
									"Update":"u",
									"ConditionalUpdate":"u",
									"Delete":"d",
									:"cruds")
	// ToDo: check Operation, Batch and Batch

	$$$FSLog("handlerMethod = " _ pHandlerMethod _ " --> tSMART2PrivNeeded = " _ tSMART2PrivNeeded)
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...Interactions: SMART2PrivNeeded handlerMethod = " _ pHandlerMethod _ " --> tSMART2PrivNeeded = " _ tSMART2PrivNeeded)

	Return tSMART2PrivNeeded
}

Method %OnNew(pStrategy As HS.FHIRServer.Storage.Json.InteractionsStrategy) As %Status
{
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...Interactions: %OnNew pStrategy = " _ pStrategy)

	Return ##Super(pStrategy)
}

/// Internal method to evaluate resource content and action against current access token
/// context and scopes. If initial call to token handler VerifyResourceContent fails,
/// and the current token has a context value in play, this method checks to see if the
/// resource has an indirect relationship to the context.
/// @API Notification that a request in about to be dispatched.  The Interactions object
/// may use this to manage any session information or other bookkeeping.  By default, no processing
/// is performed.
/// @Input pFHIRService  The instance of HS.FHIRServer.Service that invoked this method
/// @Input pFHIRRequest  The request about to be processed
/// @Input pTimeout      The maximum number of sessions between requests that session data remains valid
Method OnBeforeRequest(pFHIRService As HS.FHIRServer.API.Service, pFHIRRequest As HS.FHIRServer.API.Data.Request, pTimeout As %Integer)
{
	If (..#DOTRACE) {
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...Interactions: OnBeforeRequest pFHIRService = " _ pFHIRService _ ", pTimeout = " _ pTimeout)
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  pFHIRRequest.RequestMethod = " _ pFHIRRequest.RequestMethod _ ", pFHIRRequest.RequestPath = " _ pFHIRRequest.RequestPath)
	}

	Do ##Super(pFHIRService, pFHIRRequest, pTimeout)
	Return

	If (..#SMART2) {
		Try {
			#Dim tSMART2PrivNeeded as %String = ..SMART2PrivNeeded(pFHIRService, pFHIRRequest)


			If (tSMART2PrivNeeded = "d") {
				// ToDo: Delete is currently not verified against SMART 2.0 scopes
			}
			ElseIf ((tSMART2PrivNeeded = "c") || (tSMART2PrivNeeded = "u") || ($Length(tSMART2PrivNeeded) > 1)) {
				// If an OAuth 2.0 access token was provided with this request, verify
				// that the contents of the retrieved resource satisfy the scope(s)
				// and context of the token. This will Throw if the read was not allowed.
				Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  verifying for SMART 2.0 privilege " _ tSMART2PrivNeeded)
				Do pFHIRService.ServiceVerifyResourceContent(pFHIRRequest.Json, tSMART2PrivNeeded, 1)
			}
		}
		Catch (tEx) {
			Throw tEx
			/*
			Set tStatus = tEx.AsStatus()
			$$$FSLog("Exception in OnBeforeRequest.  tStatus = " _ tStatus)
			Do tEx.StackAsArray(.stack)
			for ord=$Get(stack,0):-1:1 { $$$FSLog("  ["_ord_"] -> "_$get(stack(ord))_" "_$get(stack(ord, "PLACE"))) }
			#Dim pFHIRRespon As HS.FHIRServer.API.Data.Request
			Do pFHIRService.SetStatusResponse(pFHIRResponse, tStatus)
			*/
		}
	}

	Do ##Super(pFHIRService, pFHIRRequest, pTimeout)
}

/// @API Notification that a request in about to be dispatched.  The Interactions object
/// may use this to manage any session information or other bookkeeping.  By default, no processing
/// is performed.
/// @Input pFHIRService  The instance of HS.FHIRServer.Service that invoked this method
/// @Input pFHIRRequest  The request about to be processed
/// @Input pFHIRResponse The response about to be returned
Method OnAfterRequest(pFHIRService As HS.FHIRServer.API.Service, pFHIRRequest As HS.FHIRServer.API.Data.Request, pFHIRResponse As HS.FHIRServer.API.Data.Response)
{
	If (..#DOTRACE) {
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...Interactions: OnAfterRequest pFHIRService = " _ pFHIRService)
		Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  pFHIRRequest.RequestMethod = " _ pFHIRRequest.RequestMethod _ ", pFHIRRequest.RequestPath = " _ pFHIRRequest.RequestPath)
	}

	Do ##Super(pFHIRService, pFHIRRequest, pFHIRResponse)
	Return

	If (..#SMART2) {
		Try {
			#Dim pHandlerMethod As %String = ""
			#Dim tSMART2PrivNeeded as %String = ..SMART2PrivNeeded(pFHIRService, pFHIRRequest, .pHandlerMethod)


			If ((tSMART2PrivNeeded = "s") || (tSMART2PrivNeeded = "r")) {
				// If an OAuth 2.0 access token was provided with this request, verify
				// that the contents of the retrieved resource satisfy the scope(s)
				// and context of the token. This will Throw if the read was not allowed.
				Do ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  verifying for SMART 2.0 privilege " _ tSMART2PrivNeeded)
				If (pHandlerMethod = "History") {
					Do pFHIRService.VerifyHistoryInstanceResponse(pFHIRRequest.Type, pFHIRResponse.Json, tSMART2PrivNeeded, 1)
				}
				ElseIf (pHandlerMethod = "Search") {
					// ToDo: Search is currently not verified against SMART 2.0 scopes
				}
				Else { // Read
					Do pFHIRService.ServiceVerifyResourceContent(pFHIRResponse.Json, tSMART2PrivNeeded, 1)
				}
			}
		}
		Catch (tEx) {
			Set tStatus = tEx.AsStatus()
			$$$FSLog("Exception in OnAfterRequest.  tStatus = " _ tStatus)
			Do tEx.StackAsArray(.stack)
			for ord=$Get(stack,0):-1:1 { $$$FSLog("  ["_ord_"] -> "_$get(stack(ord))_" "_$get(stack(ord, "PLACE"))) }
			Do pFHIRService.SetStatusResponse(pFHIRResponse, tStatus)
		}
	}
}

}
