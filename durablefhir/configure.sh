iris session iris -UFHIR '##class(%SYSTEM.OBJ).ImportDir("/src", "*.cls", "c" , .errlog, 1, .imported)'
iris session iris -UFHIR '##class(FHIRSMARTEx.Setup).ConfigureInstancefhir("FHIR")'