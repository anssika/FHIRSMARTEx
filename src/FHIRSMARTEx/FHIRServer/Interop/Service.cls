Include HS.FHIRServer

/// <p>An alternative implementation of the service class for using journaled alternatives of message classes
/// <class>HS.FHIRServer.Interop.Request</class> and <class>HS.FHIRServer.Interop.Response</class></p>
/// 
Class FHIRSMARTEx.FHIRServer.Interop.Service Extends HS.FHIRServer.Interop.Service
{

/// Use this method to dispatch a business invocation synchronously
Method SendRequestSync(pTargetDispatchName As %String, pRequest As %Library.Persistent, ByRef pResponse As %Library.Persistent, pTimeout As %Numeric = -1, pDescription As %String = "", ByRef pSendSyncHandling As %String) As %Status
{
	#dim tStatus As %Status = $$$OK

	#Dim tRequest As FHIRSMARTEx.FHIRServer.Interop.Request
	Set tRequest = ##class(FHIRSMARTEx.FHIRServer.Interop.Request).FromHSRequest(pRequest)
	#Dim tResponse As FHIRSMARTEx.FHIRServer.Interop.Response

	// Now dispatch with timeout
	Set tStatus = ##Super(..TargetConfigName, tRequest, .tResponse, ..Timeout)

	If ($IsObject($Get(tResponse))) {
		Set pResponse = tResponse.ToHSResponse()
	}

	Return tStatus
}

}
