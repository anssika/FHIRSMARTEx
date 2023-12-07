# FHIRSMARTREx
Example of a configuration including FHIR server, Authorisation server and FHIR clients all implemented using IRIS

## To start

To download, build and start this demo:
* in your local disk, go to the parent directory of this demo
* clone the source of this demo_ ´´´git clone <thisrepository>´´´
* create & start using ´´´./setup.sh´´´

## To access

Management portal: https://localhost:58021/csp/sys/UtilHome.csp
Management portal: http://localhost:58011/csp/sys/UtilHome.csp
PWS: http://localhost:58001/csp/sys/UtilHome.csp

## To stop

To stop: ´´´docker compose stop´´´

## ToDo - prio 1

See method CreateFHIRServer of class FHIRSMARTEx.Install - the commented code

## ToDo - prio 2

resource for database FHIR: %DB_%DEFAULT --> %DB_FHIR (resource exists)

## Relevant documentation for the developer of this project
* [IRIS CPF Merge](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=ACMF#ACMF_iris_customizing_useful_action)
* [Docker Compose File](https://docs.docker.com/compose/compose-file/)
* [Using InterSystems IRIS Containers](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=ADOCK#ADOCK_iris)
* [https://hub.docker.com/u/intersystems](https://hub.docker.com/u/intersystems)

## Potentially relevant documentation for the developer of this project
* [GitHub CLI manual](https://cli.github.com/manual/)
