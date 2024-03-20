Class FHIRSMARTEx.About Extends %CSP.Page
{

Parameter FHIRENDPOINTURL = "/cfsacute/fhir/r4";

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK

	&html<
		<html>
			<head>
				<style> 
					table, th, td {
					  border: 1px solid black;
					  border-collapse: collapse;
					}
				</style>
			</head>
			<body>
		>

	&html<<p>>
	Do ..OnHeaderLinks()
	&html<<br></p>>

	Set tStatus = ..OnBody()

	&html<
		</body>
		</html>
		>

	Return tStatus
}

ClassMethod OnHeaderLinks()
{
	&html<<a href="FHIRSMARTEx.About.cls">Home</a>>
}

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	Try {

		// About
		&Html<<h2>About</h2>>

		&Html<<p>
		Examples of customising and using FHIR and OAuth2 capabilities of IRIS for Health Data Platform.
		</p>>

		// Demo
		&Html<<h2>To demonstrate</h2>>

		&Html<<p><a href="FHIRSMARTEx.Client.IRIS.EHR.cls">EHR for demonstrating SMART App Launch</a><br></p>>

		// Some links to FHIRSMARTEx
		&Html<<h2>Some links to FHIRSMARTEx</h2>>

		&Html<<p>
			<a href="/csp/sys/%25CSP.Portal.Home.zen">Management Portal Home</a><br>
			<a href="/csp/bin/Systems/Module.cxw">Web Gateway Management</a><br>
		</p>>

		// Some links to elsewhere
		&Html<<h2>Links to sources of information</h2>>

		&Html<<p><a href="https://hl7.org/fhir/smart-app-launch/">SMART App Launch (of HL7)</a><br></p>>

		// Some links to elsewhere
		&Html<<h2>Links to IRIS documentation</h2>>

		&Html<<p>
			<a href="https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls">IRIS for Health - latest</a><br>
			<a href="https://docs.intersystems.com/irisforhealthlatest/csp/documatic/%25CSP.Documatic.cls">IRIS for Health - latest - Class Reference</a><br>
			<a href="https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSA_config_oauth">IRIS for Health - latest - Support for OAuth 2.0 and OpenID Connect</a><br>
		</p>>

	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

}
