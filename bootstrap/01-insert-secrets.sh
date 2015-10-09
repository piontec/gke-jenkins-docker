#!/bin/bash

source ../etc/config

NAME=secrets_jenkins-proxy
SECRETS_FILE=../${WF}/${NAME}.yaml
SECRETS_TMP_FILE=../${TMP}/${NAME}.t.yaml
CERT=jenkins
DH=dhparam.pem
CERTS_DIR=certs

echo "Encoding secrets into kubernetes secrets file..."
crt=`base64 -i ${CERTS_DIR}/${CERT}.crt`
key=`base64 -i ${CERTS_DIR}/${CERT}.key`
dh=`base64 -i ${CERTS_DIR}/dhparam.pem`

echo "Creating secrets file from template..."

sed "s/proxycert: ''/proxycert: '${crt}'/; s/proxykey: ''/proxykey: '${key}'/; s/dhparam: ''/dhparam: '${dh}'/" $SECRETS_TMP_FILE > $SECRETS_FILE

echo "done"
