Class FHIRSMARTEx.FHIRServer.Util.OAuth2Token Extends HS.FHIRServer.Util.OAuth2Token
{

Method ValidateToken() [ Private ]
{
	Return ##Super()

 $$$FSLog("Ak******************** ValidateToken() starts")
	// Must specify an OAuth 2.0 Client name if going to handle a token.
	If (..%TokenString '= "") && (..%OAuthClient = "") {
		$$$FSLog("OAuth access token received on end point that has no OAuth 2.0 Client defined")
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	}
	
	// Attempt token introspection first.
	Set introStatus = ..GetIntrospection(.introJWTObj)
	
	$$$FSLog("GetIntrospection returned status = " _ $Select($$$ISERR(introStatus):$system.Status.GetErrorText(introStatus), 1:1))
	
	If $$$ISOK(introStatus) {
		
		If $IsObject(introJWTObj) {
			// Guard against customization returning object without active.
			If introJWTObj.active {
				Set ..%TokenObject = introJWTObj
				$$$FSLog("Using JWTObj from introspection")
				Set ..%LastIntrospectionTime = ..TimeInSeconds($ztimestamp, 0)
				
			} Else {
				$$$FSLog("GetIntrospection returned invalid or inactive OAuth access token")
				$$$ThrowFHIR($$$HttpOnlyResponse(401))
			}
		
		} Else {
			// Success status without returned token is invalid.
			$$$FSLog("No token object returned by GetIntrospection")
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
		
	} Else {
		// Error code 8876 is $$$OAuth2NoEndpoint in %SYS. The lack of
		// an introspection endpoint is not considered fatal here. The
		// token obtained via ValidateJWT() will be used as a fallback.
		If $System.Status.Equals(introStatus, 8876) {
			Set ..%HasIntrospectionEP = 0
		} Else {
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
	}
	
	$$$FSLog("HasIntrospectionEP=" _ ..%HasIntrospectionEP)
	
	$$$FSLog("AlreadyValidated=" _ ..#AlreadyValidated)
	
	// If introspection failed but allowed execution to continue, then
	// use ValidateJWT() to get an object from the token string.
	// If introspection succeeded and the token was not yet validated
	// via ValidateJWT(), then call ValidateJWT().
	If ('..#AlreadyValidated) || ('$IsObject(introJWTObj)) {
		// ValidateJWT() verifies that the token is sensical as a JWT, is not expired,
		// came from the correct issuer, along with other vital information.
 $$$FSLog("Ak******************** calling ValidateJWT()")
		Set tReturn = ##class(%SYS.OAuth2.Validation).ValidateJWT(..%OAuthClient, ..%TokenString, "", "", .JWTObj, .securityParams, .tSC)		
		If $$$ISERR(tSC)  {
			$$$FSLog("ValidateJWT on OAuth access token failed: " _ $system.Status.GetErrorText(tSC))
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
		
		// If a token object was not obtained via introspection, then set
		// ..%TokenObject to the object obtained from ValidateJWT().
		If '$IsObject(introJWTObj) {
			Set ..%TokenObject = JWTObj
			$$$FSLog("Using JWTObj from ValidateJWT()")
		}
	}
	
	If '..#AlreadyValidated {
		
		// Ensure that a JWT is signed. If ..#AlreadyValidated is 0,
		// then securityParams should have been set by ValidateJWT().
		If '$Data(securityParams("sigalg"))#2 {
			$$$FSLog("OAuth access token is not signed")
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
		
		// Validate the audience.
		If '..ValidateAudience() {
			$$$FSLog("Token aud failed validation")
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
		
		// Validate the sub.
 $$$FSLog("Ak******************** calling ValidateSub()")
		If '..ValidateSub() {
			$$$FSLog("Token sub failed validation")
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
	}
	
 $$$FSLog("Ak******************** calling ValidateSub()")
	Do ..SetScopes()
	
	Do ..SetContextValues()
	
	// Ensure that the scopes and context are reasonably sensical.
	// - Must have at least one scope.
	// - Must have at least one patient or user clinical scope.
	// - If a patient clinical scope is present, then patient context must also be present.
	// Patient context value could be present for reasons other than applying patient
	// scopes, therefore patient context without patient scope is allowed.
	
	If ..%ScopesList = "" {
		$$$FSLog("No scopes found in access token")
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	} ElseIf '($Data(..%ClinicalScopes("patient")) || $Data(..%ClinicalScopes("user"))) {
		$$$FSLog("No patient or user clinical scopes found in access token")
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	} ElseIf ($Data(..%ClinicalScopes("patient"))) && ('$Data(..%ContextValues("patient"))) {
		$$$FSLog("No patient context provided for patient clinical scope in access token")
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	}
	
	$$$FSLog("Access token PASSED validation by " _ $$$CurrentMethod)
	
	Return
}

}
