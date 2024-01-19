Class FHIRSMARTEx.FHIRServer.Storage.Json.InteractionsStrategy Extends HS.FHIRServer.Storage.Json.InteractionsStrategy
{

Parameter StrategyKey As %String = "FHIRSMARTEx.Json";

Parameter InteractionsClass As %String = "FHIRSMARTEx.FHIRServer.Storage.Json.Interactions";

/// 1 = create a customized conformance satement, 0 = create standard conformance satement of IRIS for Health
Parameter CUSTOMMETADATA = 1;

/// 1 = add trace message, 0 = do not add trace messages
Parameter DOTRACE = 1;

/// @API<br>
/// Return a CapabilityStatement metadata resource. The returned content is derived from
/// a strategy-specific means of formulating a CapabilityStatement. An example use of the
/// output might be to store the CapabilityStatement for a given Service.<br>
/// This method should not be confused with the Interactions class LoadMetadata() method,
/// which retrieves the stored CapabilityStatement for the current Service.
Method GetMetadataResource() As %DynamicObject
{
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...InteractionsStrategy: GetMetadataResource")

	Return:'..#CUSTOMMETADATA ##Super()

	// Custom code starts here

	#Dim capabilityStatement As %DynamicObject = ##Super()

	// Replace the object resource of rest-object with mode = "server" with a custom resource
	If $IsObject(capabilityStatement.rest) {
		For restIdx = 0:1:capabilityStatement.rest.%Size()-1 {
			Set rest = capabilityStatement.rest.%Get(restIdx)
			If rest.mode = "server" {
				Set resource = ..CustomizeResourceMetadata(rest.resource)
				If ($IsObject(resource)) && (resource.%Size()) {
					// If server was built here, then replace the original server with this custom one
					Set rest.resource = resource
				}
			}
		}
	}

	Return capabilityStatement
}

ClassMethod CustomizeResourceMetadata(pResourceArray As %DynamicArray) As %DynamicArray
{
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...InteractionsStrategy: CustomizeResourceMetadata:")

	#Dim tResourceArray As %DynamicArray = []

	#Dim tObjI As %Integer
	For tObjI = 0:1:pResourceArray.%Size()-1 {
		#Dim tResource As %DynamicObject = pResourceArray.%Get(tObjI)
		If (tResource.type = "Patient") {
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  Adding pResource.type = " _ tResource.type)
			Do tResourceArray.%Push(..CustomizePatientMetadata(tResource))
		}
		ElseIf (tResource.type = "Encounter") {
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  Adding pResource.type = " _ tResource.type)
			Do tResourceArray.%Push(tResource)
		}
		Else {
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  Skipping pResource.type = " _ tResource.type)

		}
	}

	Return tResourceArray
}

ClassMethod CustomizePatientMetadata(pPatientMetadata As %DynamicObject) As %DynamicObject
{
	Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("FHIRSMARTEx...InteractionsStrategy: CustomizePatientMetadata:")

	#Dim tPatientMetadata As %DynamicObject = pPatientMetadata

	#Dim tObjI As %Integer
	For tObjI = tPatientMetadata.interaction.%Size()-1:-1:0 {
		If ((tPatientMetadata.interaction.%Get(tObjI).code = "create") || (tPatientMetadata.interaction.%Get(tObjI).code = "delete")) {
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  Deleting interaction with code " _ tPatientMetadata.interaction.%Get(tObjI).code)
			Do tPatientMetadata.interaction.%Remove(tObjI)
		}
		Else {
			Do:..#DOTRACE ##class(FHIRSMARTEx.Util.SimpleTrace).Append("  Keeping interaction with code " _ tPatientMetadata.interaction.%Get(tObjI).code)

		}
	}

	Return tPatientMetadata
}

ClassMethod RecreateMetadata()
{
	#dim tStrategy as HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint("/fhir/r4")
	if '$IsObject(tStrategy) {
		$$$ThrowFHIR($$$GeneralError, "Unable to create Storage Strategy Class")
	}
	Set interactions = tStrategy.NewInteractionsInstance()
	do interactions.SetMetadata( tStrategy.GetMetadataResource() )
}

}
