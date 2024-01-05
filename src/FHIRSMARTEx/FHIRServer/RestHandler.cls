/// This class exists in ordet to HANG it long enough to attach to it with debugger
/// 
/// To "activate" this class, edit the Web Application of the FHIR server
Class FHIRSMARTEx.FHIRServer.RestHandler Extends HS.FHIRServer.RestHandler
{

ClassMethod processRequest(pRequestPath As %String) As %Status
{
	Return ##Super(pRequestPath)
}

/// Override of %CSP.REST OnPreDispatch(). This method gets called prior to dispatch
/// of EVERY request. If this method sets pContinue to 0, the request will NOT be
/// dispatched according to the UrlMap. In that case it is the responsibility of
/// this method to return a response.
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	Return ##Super(pUrl, pMethod, .pContinue)

 //HANG 10		// Some time to attach to a process with a debugger
 Set tAk = $Increment(^Ak)
 Set ^Ak(tAk) = $ZDateTime($H, 3) _ ": " _ $Job

	Kill %tokenhandlerobj
	
	// Check the basics - is there a token, is token in header, is token on secure connection.
	Do ..PrelimTokenCheck(.accessToken, .httpStatus, .exception, .failReason)
 Set tAk = $Increment(^Ak)
 Set ^Ak(tAk) = $ZDateTime($H, 3) _ ": PrelimTokenCheck returned httpStatus = " _ httpStatus _ ", accessToken = " _ accessToken
	
	If (httpStatus = "") && (accessToken '= "") && ('..IsPrelimTokenCheckOnly()) {
		// If there is a token, and no problems so far, and further checking is allowed,
		// then validate the token per the token handler for the current endpoint.
		Do ..ValidateOAuthToken(.accessToken, .tokenHandlerObj, .httpStatus, .exception, .failReason)
 Set tAk = $Increment(^Ak)
 Set ^Ak(tAk) = $ZDateTime($H, 3) _ ": ValidateOAuthToken returned httpStatus = " _ httpStatus
	}
	
	If httpStatus '= "" {
		// httpStatus with a value means there was a fail during token checking.
		
		Set pContinue = 0
		
		// Do logging only if we are not proceeding to processRequest().
		Set methodDesc = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		Do ..LogCSPRequest(methodDesc, 1)
		
		If +httpStatus = 401 {
			// If an access token was provided with the request, and the request was
			// rejected with 401 Unauthorized, then fill in the WWW-Authenticate
			// response header. Rejection because of not using https does not count
			// as bad access token. Rejection because of placing the token in the
			// URL or in the form encoded body does not count as bad access token.
			If '((failReason = "url") || (failReason = "unsecure") || (failReason = "internal_error")) {
				Do %response.SetHeader("WWW-Authenticate", "Bearer")
			}
			Set %response.Status = httpStatus
			
		} ElseIf $IsObject(exception) {
			Do ..ReportHttpStatusCode(httpStatus, exception.AsStatus())
			
		} Else {
			Do ..ReportHttpStatusCode(httpStatus)
		}
		
		Do ..LogCSPResponse(methodDesc, 1)
		
		Quit $$$OK
	}
	
	Set %tokenhandlerobj = $Get(tokenHandlerObj)
	
	Quit $$$OK
}

}
