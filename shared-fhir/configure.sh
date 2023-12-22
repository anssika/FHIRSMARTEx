iris session iris -UFHIR 'Do ##class(%SYSTEM.OBJ).ImportDir("/src", "*.cls", "c" , .errlog, 1, .imported)'
iris session iris -UFHIR 'Do ##class(FHIRSMARTEx.Setup).ConfigureInstancefhir("FHIR")'
iris session iris -U%SYS 'Do ##class(%SYSTEM.OBJ).ImportDir("/src", "*.cls", "c" , .errlog, 1, .imported)'
iris session iris -U%SYS 'Do ##class(FHIRSMARTEx.Setup).ConfigureInstanceoauth2("%SYS")'