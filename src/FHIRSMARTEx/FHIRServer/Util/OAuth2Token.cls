Class FHIRSMARTEx.FHIRServer.Util.OAuth2Token Extends HS.FHIRServer.Util.OAuth2Token
{

/// 1 = support SMART 2.0 scopes (one of cruds), 0 = do not support
Parameter SMART2 = 1;

/// 1 = add trace message, 0 = do not add trace messages
Parameter DOTRACE = 1;

/// Added support for SMART 2.0 scopes (and some tracing)
/// 
/// Parses the token JWT object "scope" property and populates %ScopesList and %ClinicalScopes.
Method SetScopes() [ Private ]
{
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...OAuth2Token: SetScopes:")

	Set scopesList = ""
	
	Set scopesString = ..%TokenObject.scope
	
	$$$FSLog("scope string = " _ scopesString)
	
	For i = 1:1:$Length(scopesString," ") {
		Set nextScope = $Piece(scopesString," ",i)
		Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  processing scope = " _ nextScope)
		Continue:nextScope=""
		Set $List(scopesList, *+1) = nextScope
		If $Extract(nextScope, 1, 8) = "patient/" {
			Set clinicalScopeName = "patient"
		} ElseIf $Extract(nextScope, 1, 5) = "user/" {
			Set clinicalScopeName = "user"
		} Else {
			Set clinicalScopeName = ""
		}
		If clinicalScopeName '= "" {
			Set scopeTypeAndRW = $Piece(nextScope, "/", 2)
			Set scopeResourceType = $Piece(scopeTypeAndRW, ".", 1)
 			Set scopeReadWrite = $Piece(scopeTypeAndRW, ".", 2)
 			Set N = $Get(..%ClinicalScopes(clinicalScopeName)) + 1
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    N = " _ N)
			// The if - just the if - is custom code
			// the content of the if block is original code
			If (('..#SMART2) || ('..IsSMART2Scope(scopeReadWrite))) {
				// The original code
				// Add non SMART 2.0 (SMART 1.0) scopes in any case
				Set ..%ClinicalScopes(clinicalScopeName, N, "resourceType") = scopeResourceType
				Set ..%ClinicalScopes(clinicalScopeName, N, "readWrite") = scopeReadWrite
				Set ..%ClinicalScopes(clinicalScopeName) = N
				Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    allowed scope " _ scopeResourceType _ "." _ scopeReadWrite)
				$$$FSLog("allowing scope " _ nextScope)
			}
			// Start of custom code
			If (..#SMART2 && ..IsSMART2Scope(scopeReadWrite)) {
				$$$FSLog("allowing SMART 2.0 scope(s) " _ nextScope)
				For i=1:1:$Length(scopeReadWrite) {
					#Dim tScopeReadWrite As %String = $Extract(scopeReadWrite, i)
					// Allow SMART 2.0 scope
					Set ..%ClinicalScopes(clinicalScopeName, N, "resourceType") = scopeResourceType
					Set ..%ClinicalScopes(clinicalScopeName, N, "readWrite") = tScopeReadWrite
					Set ..%ClinicalScopes(clinicalScopeName) = N
					Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    allowed scope " _ scopeResourceType _ "." _ tScopeReadWrite)
					If ((tScopeReadWrite = "r") || (tScopeReadWrite = "s")) {
						// Allow SMART 1.0 scope corresponding the SMART 2.0 scope
						Set ..%ClinicalScopes(clinicalScopeName, N, "resourceType") = scopeResourceType
						Set ..%ClinicalScopes(clinicalScopeName, N, "readWrite") = "read"
						Set ..%ClinicalScopes(clinicalScopeName) = N
						Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    allowed scope " _ scopeResourceType _ "." _ "read")
					}
					If ((tScopeReadWrite = "c") || (tScopeReadWrite = "u") || (tScopeReadWrite = "d")) {
						// Allow SMART 1.0 scope corresponding the SMART 2.0 scope
						Set ..%ClinicalScopes(clinicalScopeName, N, "resourceType") = scopeResourceType
						Set ..%ClinicalScopes(clinicalScopeName, N, "readWrite") = "write"
						Set ..%ClinicalScopes(clinicalScopeName) = N
						Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    allowed scope " _ scopeResourceType _ "." _ "read")
					}
				}
			}
			// End of custom code
			
		} Else {
			$$$FSLog("dropping scope " _ nextScope)
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("    discarding scope = " _ nextScope)
		}
	}
	
	Set ..%ScopesList = scopesList
	
	Return
}

ClassMethod IsSMART2Scope(readWrite As %String) As %Boolean
{
	// ToDo: more robust implementation

	If ((readWrite = "read") || (readWrite = "write")) return 0
	If (($Length(readWrite) < 1) || ($Length(readWrite) > 5)) return 0
	Return 1
}

}
