/// <p>An alternative implementation of the operation class for using journaled alternatives of message classes
/// <class>HS.FHIRServer.Interop.Request</class> and <class>HS.FHIRServer.Interop.Response</class></p>
/// 
Class FHIRSMARTEx.FHIRServer.Interop.Operation Extends HS.FHIRServer.Interop.Operation
{

XData MessageMap
{
<MapItems>
	<MapItem MessageType="FHIRSMARTEx.FHIRServer.Interop.Request">
		<Method>DispatchRequest2</Method>
	</MapItem>
</MapItems>
}

Method DispatchRequest2(pInteropRequest As FHIRSMARTEx.FHIRServer.Interop.Request, Output pInteropResponse As FHIRSMARTEx.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tRequest As HS.FHIRServer.Interop.Request = $$$NULLOREF
	#Dim tResponse As HS.FHIRServer.Interop.Response = $$$NULLOREF

	Try {
		Set tRequest = pInteropRequest.ToHSRequest()
		Set tStatus = ..DispatchRequest(tRequest, .tResponse)
		// It is important to not change the value of tStatus before returning it
		If ($IsObject(tResponse)) {
			Set pInteropResponse = ##class(FHIRSMARTEx.FHIRServer.Interop.Response).FromHSResponse(tResponse)
		}
	} Catch tException {
		If ($$$ISERR(tStatus)) {
			// Do not hide the error that happened earlier
			$$$LOGERROR("Call of ..DispatchRequest() returned error status (before of this exception): " _ ##class(%SYSTEM.Status).GetErrorText(tStatus))
		}
		Set tStatus = tException.AsStatus()
	}

	// Clear the QuickStreams: of both the request and the response
	// The QuickStreams are stored in global ^CacheTemp.HS.Stream 
	#Dim tQuickStream As HS.SDA3.QuickStream
	If ($IsObject(tRequest) && (tRequest.QuickStreamId '= "")) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%OpenId(tRequest.QuickStreamId)
		Do tQuickStream.Clear(1)
	}
	If ($IsObject(tResponse) && (tResponse.QuickStreamId '= "")) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%OpenId(tResponse.QuickStreamId)
		Do tQuickStream.Clear(1)
	}

	Return tStatus
}

}
