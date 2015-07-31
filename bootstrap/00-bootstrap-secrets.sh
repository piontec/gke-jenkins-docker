#!/bin/bash

source ../etc/config

NAME=secrets_jenkins-proxy
SECRETS_FILE=../${WF}/${NAME}.yaml
SECRETS_TMP_FILE=../${TMP}/${NAME}.t.yaml
CERT=jenkins
DH=dhparam.pem
CERTS_DIR=certs

echo "Preparing secrets for SSL proxy used to access jenkins..."

if [ ! -d ../${WF} ]; then
	mkdir ../${WF}
fi

cp -a ../inputs/* ../${WF}/

if [ ! -d ${CERTS_DIR} ]; then
	mkdir ${CERTS_DIR}
fi

if [ -f ${CERTS_DIR}/${CERT}.crt ]; then
	echo "Certificate file exists, using it instead of generating a new one"
else
	echo "Generating certs..."
	./gencert.sh ${CERTS_DIR}/$CERT
fi

if [ -f ${CERTS_DIR}/${DH} ]; then
	echo "${CERTS_DIR}/${DH} file exists, using it instead of generating a new one"
else	
	echo "Generating DH..."
	openssl dhparam -out ${CERTS_DIR}/${DH} 2048
fi

echo "done"
