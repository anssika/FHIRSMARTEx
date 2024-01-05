#!bin/bash

iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END

Zn "%SYS"
Do ##class(%SYSTEM.OBJ).ImportDir("/src/FHIRSMARTEx/Setup", "*.cls", "c" , .errlog, 1, .imported)
Do ##class(FHIRSMARTEx.Setup.OAuth2Server).Setup()
Zn "FHIR"
Do ##class(%SYSTEM.OBJ).ImportDir("/src", "*.cls", "c" , .errlog, 1, .imported)
Do ##class(FHIRSMARTEx.Setup.OAuth2Clients).Setup()
Do ##class(FHIRSMARTEx.Setup.FHIRServer).Setup()

Halt
END

exit 0