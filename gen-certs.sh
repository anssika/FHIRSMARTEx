#!/bin/sh

# Common parameters

RSA_KEY_NUMBITS="2048"
DAYS="365"

GenCA() {
    local SUBJ=$1
    local CERT_FILE=$2
   
	echo " creating key ..."
	openssl genrsa \
		-out "$CERT_FILE.key" \
		"$RSA_KEY_NUMBITS"

	echo " creating csr ..."
	openssl req \
		-new \
		-key "$CERT_FILE.key" \
		-out "$CERT_FILE.csr" \
		-subj "$SUBJ"

	echo " creating cer ..."
	openssl req \
		-x509 \
		-key "$CERT_FILE.key" \
		-in "$CERT_FILE.csr" \
		-out "$CERT_FILE.cer" \
		-days "$DAYS"
    
    #cat $CERT_CA.cer >> "$CERT_FNAME.cer"
}

GenCertificate() {
    local SUBJ=$1
    local CERT_FILE=$2
    local CERT_CA=${3:-./CA.cer}
   
	echo " creating key ..."
	openssl genrsa \
	    -out "$CERT_FILE.key" \
	    "$RSA_KEY_NUMBITS"
    
	echo " creating csr ..."
    openssl req \
        -new \
        -key "$CERT_FILE.key" \
        -out "$CERT_FILE.csr" \
        -subj "$SUBJ"

	echo " creating cer ..."
    openssl x509 \
        -req \
        -in "$CERT_FILE.csr" \
        -CA "$CERT_CA.cer" \
        -CAkey "$CERT_CA.key" \
        -out "$CERT_FILE.cer" \
        -CAcreateserial \
        -days "$DAYS"
    
    #cat $CERT_CA.cer >> "$CERT_FNAME.cer"
}

# create folder for certificates
if [ -d "./certificates" ]
then
	echo "removing folder .certificates ..."
	rm -rf ./certificates
fi

echo "creating folder .certificates for the certificates ..."
mkdir certificates
cd certificates

# create CA
echo "creating CA ..."
CA_FILE="CA"
GenCA "/C=FI/ST=Finland/L=testL/O=testO/OU=testOU/CN=testCA" $CA_FILE

# superserver
#echo "creating certificate for SuperServer ..."
#GenCertificate "/C=FI/ST=Finland/L=testL/O=testO/OU=testOU/CN=iris" "superserver" $CA_FILE

# HTTP server --> fhir
echo "creating certificate for HTTP server of fhir ..."
GenCertificate "/C=FI/ST=Finland/L=testL/O=testO/OU=testOU/CN=wg-fhir" "wg-fhir" $CA_FILE
echo "copying to ../shared-wg-fhir"
cp wg-fhir.cer ../shared-wg-fhir
cp wg-fhir.key ../shared-wg-fhir

