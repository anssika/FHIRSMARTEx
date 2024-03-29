/// This does not work ...
/// 
Class FHIRSMARTEx.Client.SMARTHealthIT.ConfidentialSymmetric.Index Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	#Dim tThisPage As %String = $Get(%request.CgiEnvs("REQUEST_SCHEME")) _ "://" _ $Get(%request.CgiEnvs("HTTP_HOST")) _ $Get(%request.CgiEnvs("REQUEST_URI"))
	If (0) {
		&html<<html><body>>
		&html<<p>tThisPage = #(tThisPage)#</p>>
		&html<</body></html>>
		Return $$$OK
	}
	/*
	 * This is from https://docs.smarthealthit.org/tutorials/javascript/
	 *
	 */

	&html<

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <title>Example SMART App</title>
        <script src="https://cdn.jsdelivr.net/npm/fhirclient/build/fhir-client.js"></script>
        <style>
            #patient, #meds {
                font-family: Monaco, monospace;
                white-space: pre;
                font-size: 13px;
                height: 30vh;
                overflow: scroll;
                border: 1px solid #CCC;
            }
        </style>
    </head>
    <body>
 		<p>tThisPage = #(tThisPage)#</p>
       <h4>Current Patient</h4>
        <div id="patient">Loading...</div>
        <br/>
		<!-- Medications removed 12.3.2024
        <h4>Medications</h4>
        <div id="meds">Loading...</div>
		-->
        <script type="text/javascript">
            FHIR.oauth2.ready().then(function(client) {
                
                // Render the current patient (or any error)
                client.patient.read().then(
                    function(pt) {
                        document.getElementById("patient").innerText = JSON.stringify(pt, null, 4);
                    },
                    function(error) {
                        document.getElementById("patient").innerText = error.stack;
                    }
                );
                
			/*	Medications removed 12.3.2024
                // Get MedicationRequests for the selected patient
                client.request("/MedicationRequest?patient=" + client.patient.id, {
                    resolveReferences: [ "medicationReference" ],
                    graph: true
                })
                
                // Reject if no MedicationRequests are found
                .then(function(data) {
                    if (!data.entry || !data.entry.length) {
                        throw new Error("No medications found for the selected patient");
                    }
                    return data.entry;
                })
                

                // Render the current patient's medications (or any error)
                .then(
                    function(meds) {
                        document.getElementById("meds").innerText = JSON.stringify(meds, null, 4);
                    },
                    function(error) {
                        document.getElementById("meds").innerText = error.stack;
                    }
                );
			*/
            }).catch(console.error);
        </script>
    </body>
</html>
>
	Return $$$OK
}

}
