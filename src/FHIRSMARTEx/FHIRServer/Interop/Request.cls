/// <p>A journaled alternative to class <class>HS.FHIRServer.Interop.Request</class></p>
/// 
/// <p>To use this class, you need to extend classes <class>HS.FHIRServer.Interop.Service</class> 
/// and <class>HS.FHIRServer.Interop.Operation</class> and possibly other interoperability classes accordingly</p>
/// 
/// <p>For some insight on the use of class <class>HS.FHIRServer.Interop.Response</class>, take a look at the source code of class <class>HS.FHIRServer.RestHandler</class></p>
/// 
Class FHIRSMARTEx.FHIRServer.Interop.Request Extends HS.Util.EnsRequest [ StorageStrategy = "" ]
{

Property Request As HS.FHIRServer.API.Data.Request;

/// Request payload.
Property Payload As %Stream.GlobalCharacter;

Parameter RESPONSECLASSNAME = "CFSAcute.FHIRServer.Interop.Response";

ClassMethod FromHSRequest(pRequest As HS.FHIRServer.Interop.Request) As FHIRSMARTEx.FHIRServer.Interop.Request
{
	#Dim tRequest As FHIRSMARTEx.FHIRServer.Interop.Request = ..%New()

	Set tRequest.Request = pRequest.Request
	if (pRequest.QuickStreamId '= "") {
		#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%OpenId(pRequest.QuickStreamId)
		Do tRequest.Payload.CopyFrom(tQuickStream)
	}

	Return tRequest
}

Method ToHSRequest() As HS.FHIRServer.Interop.Request
{
	#Dim tRequest As HS.FHIRServer.Interop.Request = ##class(HS.FHIRServer.Interop.Request).%New()

	Set tRequest.Request = ..Request
	if ($IsObject(..Payload) && (..Payload.Size)) {
		#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%New()
		Do tQuickStream.CopyFrom(..Payload)
		Set tRequest.QuickStreamId = tQuickStream.%Id()
	}

	Return tRequest
}

Storage Default
{
<Data name="RequestDefaultData">
<Subscript>"Request"</Subscript>
<Value name="1">
<Value>Request</Value>
</Value>
<Value name="2">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>RequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
