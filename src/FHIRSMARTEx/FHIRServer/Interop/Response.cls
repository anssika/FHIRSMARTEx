/// <p>A journaled alternative to class <class>HS.FHIRServer.Interop.Response</class></p>
/// 
/// <p>To use this class, you need to extend classes <class>HS.FHIRServer.Interop.Service</class> 
/// and <class>HS.FHIRServer.Interop.Operation</class> and possibly other interoperability classes accordingly</p>
/// 
/// <p>For some insight on the use of class <class>HS.FHIRServer.Interop.Response</class>, take a look at the source code of class <class>HS.FHIRServer.RestHandler</class></p>
/// 
Class FHIRSMARTEx.FHIRServer.Interop.Response Extends HS.Util.EnsResponse [ StorageStrategy = "" ]
{

Property Response As HS.FHIRServer.API.Data.Response;

/// Response payload.
Property Payload As %Stream.GlobalCharacter;

/// HTTP response Charset value.
Property CharSet As %String;

/// HTTP response Content-Type header.
Property ContentType As %String(MAXLEN = 8192);

ClassMethod FromHSResponse(pResponse As HS.FHIRServer.Interop.Response) As FHIRSMARTEx.FHIRServer.Interop.Response
{
	#Dim tResponse As FHIRSMARTEx.FHIRServer.Interop.Response = ..%New()

	Set tResponse.Response = pResponse.Response
	If (pResponse.QuickStreamId '= "") {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%OpenId(pResponse.QuickStreamId)
		Do tResponse.Payload.CopyFrom(tQuickStream)
	}
	Set tResponse.CharSet = pResponse.CharSet
	Set tResponse.ContentType = pResponse.ContentType

	Return tResponse
}

Method ToHSResponse() As HS.FHIRServer.Interop.Response
{
	#Dim tResponse As HS.FHIRServer.Interop.Response = ##class(HS.FHIRServer.Interop.Response).%New()

	Set tResponse.Response = ..Response
	if ($IsObject(..Payload) && (..Payload.Size)) {
		#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%New()
		Do tQuickStream.CopyFrom(..Payload)
		Set tResponse.QuickStreamId = tQuickStream.%Id()
	}
	Set tResponse.CharSet = ..CharSet
	Set tResponse.ContentType = ..ContentType

	Return tResponse
}

Storage Default
{
<Data name="ResponseDefaultData">
<Subscript>"Response"</Subscript>
<Value name="1">
<Value>Response</Value>
</Value>
<Value name="2">
<Value>Payload</Value>
</Value>
<Value name="3">
<Value>CharSet</Value>
</Value>
<Value name="4">
<Value>ContentType</Value>
</Value>
</Data>
<DefaultData>ResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
