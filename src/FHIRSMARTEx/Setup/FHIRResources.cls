Class FHIRSMARTEx.Setup.FHIRResources Extends %RegisteredObject
{

Parameter FHIRURL = "/fhir/r4";

ClassMethod Setup()
{
	Do ..CreateUpdateFHIRResources()
}

ClassMethod CreateUpdateFHIRResources()
{
	#Dim tStatus As %Status = $$$OK

	#Dim tException As %Exception.AbstractException
	Try {
		#Dim tPatientResource As %String = ..XDataAsString("SMARTPatientR4")

		New $Namespace
		Set $Namespace = "fhir"

		Write " Creating client instance for " _ ..#FHIRURL _ " ...", !
		#Dim tFHIRClient As HS.FHIRServer.RestClient.FHIRService
		Set tFHIRClient = ##class(HS.FHIRServer.RestClient.FHIRService).CreateInstance(..#FHIRURL)
		Do tFHIRClient.SetRequestFormat("JSON")
		Do tFHIRClient.SetResponseFormat("JSON")

		Write " Creating/updating a Patient resource " _ ..#FHIRURL _ " ...", !
		#Dim tResponse As HS.FHIRServer.API.Data.RestClient.Response
		Set tResponse = tFHIRClient.Update("Patient", "9000", tPatientResource)
		Write "  tResponse = " _ tResponse, !
		Write "  tResponse.Status = " _ tResponse.Status, !
		Write "  tResponse.AdditionalInfo = " _ tResponse.AdditionalInfo, !
		Write "  tResponse.AdditionalInfo.Count() = " _ tResponse.AdditionalInfo.Count(), !
	}
	Catch tException {
		Set tStatus = tException.AsStatus()
	}

	Return tStatus
}

ClassMethod XDataAsString(pXDataName As %String = "SMARTPatient") As %String
{
	#Dim tResource As %String = ""

	#Dim tStatus As %Status = $$$OK
	Set tXData = ##class(%Dictionary.CompiledXData).%OpenId(..%ClassName(1) _ "||" _ pXDataName,, .tStatus)
	//Set tXData = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||" _ pXDataName,, .tStatus)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
 //Write "tXData.Data = " _ tXData.Data, !
 //Write "tXData.Data.AtEnd = " _ tXData.Data.AtEnd, !
	While ('tXData.Data.AtEnd) {
		Set tResource = tResource _ tXData.Data.Read()
 //Write "tResource = " _ tResource, !
 //Write "2: tXData.Data.AtEnd = " _ tXData.Data.AtEnd, !
	}

	Return tResource
}

/// id = 1482713
XData SMARTPatientR4 [ MimeType = application/json ]
{
{
   "resourceType" : "Patient",
   "id" : "9000",
   "text" : {
      "status" : "generated",
      "div" : "<div>\n        \n            <p>Susan Clark</p>\n      \n          </div>"
   },
   "name" : [
      {
         "given" : [
            "Susan",
            "A."
         ],
         "use" : "official",
         "family" : "Clark"
      }
   ],
   "address" : [
      {
         "country" : "USA",
         "city" : "Tulsa",
         "state" : "OK",
         "use" : "home",
         "line" : [
            "52 Highland St"
         ],
         "postalCode" : "74116"
      }
   ],
   "gender" : "female",
   "telecom" : [
      {
         "system" : "phone",
         "use" : "home",
         "value" : "800-576-9327"
      },
      {
         "system" : "email",
         "value" : "susan.clark@example.com"
      }
   ],
   "active" : true,
   "birthDate" : "2000-12-27",
   "identifier" : [
      {
         "type" : {
            "text" : "Medical record number",
            "coding" : [
               {
                  "code" : "MR",
                  "system" : "http://hl7.org/fhir/v2/0203",
                  "display" : "Medical record number"
               }
            ]
         },
         "system" : "http://hospital.smarthealthit.org",
         "value" : "1482713",
         "use" : "usual"
      }
   ]
}
}

}
