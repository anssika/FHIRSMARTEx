# FHIRSMARTREx
Demonstrates IRIS for Health configurations, customisations and implementations related to FHIR and SMART on FHIR, clients and services.

## Install

Select a parent folder for FHIRSMARTEx (e.g. C:\). Go to that folder and:
```bash
git clone https://github.com/anssika/FHIRSMARTEx.git
cd ./FHIRSMARTEx
docker-compose up -d
```

Edit your hosts file (in folder C:\Windows\System32\drivers\etc) and add the following entry:
`127.0.0.1 wg-fhir`

## To access

- This is the page to start: https://wg-fhir:58143/csp/healthshare/fhir/FHIRSMARTEx.About.cls
- Management portal / fhir: https://wg-fhir:58143/csp/sys/UtilHome.csp
- Web Gateway Management / fhir-gw: https://wg-fhir:58143/csp/bin/Systems/Module.cxw

Please use username/password **superuser**/**SYS** when logging in the first time.

After the first succesfull login, IRIS redirects you to a page to change the default password. The old password is **SYS** and the least secure choice for the new password would be **sys**.

## To stop

To stop the containers:
```bash
docker-compose stop
```
# To start again

To start the containers:
```bash
docker-compose up -d
```

## Certificates

Certificates are in place and valid for two yers after creation.

To generate and install new certicates, go to folder FHIRSMARTEx and run script (runs on Mac):
```bash
./gen_certs.sh
```