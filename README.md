# FHIRSMARTREx
Example of a configuration including FHIR server, Authorisation server and FHIR clients - all implemented using IRIS

## Install

Go to a local folder and:
```bash
git clone https://github.com/anssika/FHIRSMARTEx.git
cd ./FHIRSMARTEx
./setup.sh
```
This will also start the containers.

## To access

- Management portal / fhir: https://localhost:58143/csp/sys/UtilHome.csp
- FHIR test clients: https://wg-fhir:58143/csp/healthshare/fhir/FHIRSMARTEx.Util.CSP.Home.cls

You can user username/passwod **superuser**/**SYS** when logging in the first time.

After the first succesfull login, IRIS redirects you to a page to change the default password. The old password is **SYS** and the least secure choice for the new password would be **sys**.

## To stop

To stop the containers:
```bash
docker compose stop
```
# To start again

To start the containers:
```bash
docker compose up -d
```

## ToDo - prio 2

resource for database FHIR: %DB_%DEFAULT --> %DB_FHIR (resource exists)

## Relevant documentation for the developer of this project
* [IRIS CPF Merge](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=ACMF#ACMF_iris_customizing_useful_action)
* [Docker Compose File](https://docs.docker.com/compose/compose-file/)
* [Using InterSystems IRIS Containers](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=ADOCK#ADOCK_iris)
* [https://hub.docker.com/u/intersystems](https://hub.docker.com/u/intersystems)

## Potentially relevant documentation for the developer of this project
* [GitHub CLI manual](https://cli.github.com/manual/)
