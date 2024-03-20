Class FHIRSMARTEx.Client.IRIS.EHR Extends FHIRSMARTEx.About
{

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tAccessToken, tIdToken, tResponseProperties As %String
	#Dim tIsAuthorized As %Boolean

	&html<<h3>#(..%ClassName(1))#</h3>>

	Try {

		#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))

		/********************************************************************************
		This call
		*/

		&html<<h3>About this page</h3>>

		&html<<p>tThisPage = #(tThisPage)#</p>>

		&html<<p>
			This page demonstrates an EHR: you select a patient to work with 
			and when starting an app using SMART App Launch, that selected patient
			is reflected in the claims of the access token created by the EHR (its OAuth2 server).</p>>

		/********************************************************************************
		The current context
		*/
		#Dim tCurrentPatientId As %String = $Get(^FHIRSMARTEx.Client.IRIS.EHR("PatientId"), 9000)
		// ToDo: implement selection of current patient
		Set ^FHIRSMARTEx.Client.IRIS.EHR("PatientId") = tCurrentPatientId

		&html<<h3>You context currently</h3>>

		&html<<p>You are currently logged in as <strong>#($UserName)#</strong></p>>

		&html<<p>The id of your current patient is <strong>#(tCurrentPatientId)#</strong></p>>


		/********************************************************************************
		The clients
		*/
		&html<<h3>SMART App Launch clients</h3>>

		#Dim tISS As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ "/fhir/r4"
		&html<<p>value of HTTP argument iss to be passed to the clients = <strong>#(tISS)#</strong></p>>

		&Html<<p>
			<a href="FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Launch.cls?iss=#(tISS)#">FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Launch.cls?iss=#(tISS)#</a><br>
			<a href="FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?iss=#(tISS)#&grantType=AC">IRIS Confidential Symmetric Client (V4) using authorization code grant type (AC)</a><br>
			<a href="FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?iss=#(tISS)#&grantType=CR">IRIS Confidential Symmetric Client (V4) using client credentials grant type (CR)</a><br>
		</p>>

		/********************************************************************************
			Some utilities
		*/
		&html<<h3>Some utilities</h3>>

		&Html<<p>
			<a href="https://www.jstoolset.com/jwt">JWT Decoder</a><br>
			<a href="https://www.jstoolset.com/url-decode">URL Decoder</a><br>
			<a href="https://www.jstoolset.com/json-formatter">Json Formatter</a><br>
		</p>>

		/********************************************************************************
		The clients under development
		*/
		&html<<h3>SMART App Launch clients - next version(s) under development</h3>>

		&Html<<p>
			<a href="FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV5.cls?iss=#(tISS)#&grantType=AC">IRIS Confidential Symmetric Client (V5) using authorization code grant type (AC)</a><br>
			<a href="FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV5.cls?iss=#(tISS)#&grantType=CR">IRIS Confidential Symmetric Client (V5) using client credentials grant type (CR)</a><br>
		</p>>

		/********************************************************************************
		The old clients
		*/
		&html<<h3>Old versions of SMART App Launch clients</h3>>

		&Html<<p><a href="FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?grantType=CR">IRIS Confidential Symmetric Client (V4) using client credentials grant type</a><br></p>>

		/*
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?grantType=CR", "IRIS Confidential Symmetric Client (V4) using client credentials grant type", "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV4.cls?grantType=AC", "IRIS Confidential Symmetric Client (V4) using authorization code grant type", "<br>")

	#Dim tISS As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ "/fhir/r4"
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Launch.cls?iss=" _ tISS,, "<br>")

	&html<<br>>
	&html<<h3>Old SMART Clients - May not work any longer</h3>> 
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV3.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.ClientV2.cls",, "<br>")
	Do ..WriteLink(pBaseUrl _ "/FHIRSMARTEx.Client.IRIS.ConfidentialSymmetric.Client.cls",, "<br>")
*/

	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

}
