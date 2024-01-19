Class FHIRSMARTEx.Interop.Process.ProcessFHIRRequest Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent, ProcedureBlock ]
{

/// Name of the business host to send processed FHIR request to
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "FHIRResourceRepository" ];

/// Number of seconds to wait response from <property>TargetConfigName</property>
Property ResponseTimeout As %Numeric [ InitialExpression = 5 ];

/// If true, removes the access token from the request
Property RemoveAccesstoken As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "TargetConfigName:Basic,RemoveAccesstoken:Basic,ResponseTimeout:Basic";

Method OnRequest(pFHIRRequest As FHIRSMARTEx.FHIRServer.Interop.Request, Output pFHIRResponse As FHIRSMARTEx.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tFHIRRequest As FHIRSMARTEx.FHIRServer.Interop.Request = pFHIRRequest

	// Remove access token? (if present)?
	If ((..RemoveAccesstoken) && (pFHIRRequest.Request.AdditionalInfo.GetAt("USER:OAuthToken") '= "")) {

		// make copy of the request
		Set tFHIRRequest = tFHIRRequest.%ConstructClone(1)

		// remove the access token from the (copy of the) request
		Do tFHIRRequest.Request.AdditionalInfo.RemoveAt("USER:OAuthToken")
	}

    Set tStatus = ..SendRequestSync(..TargetConfigName, tFHIRRequest, .pFHIRResponse, ..ResponseTimeout)
	If ($$$ISERR(tStatus)) Return tStatus

	Return tStatus
}

Storage Default
{
<Data name="ProcessFHIRRequestDefaultData">
<Subscript>"ProcessFHIRRequest"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
<Value name="2">
<Value>ResponseTimeout</Value>
</Value>
<Value name="3">
<Value>RemoveAccesstoken</Value>
</Value>
<Value name="4">
<Value>TraceOperations</Value>
</Value>
</Data>
<DefaultData>ProcessFHIRRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
