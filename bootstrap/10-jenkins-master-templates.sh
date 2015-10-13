#!/bin/bash

source ../etc/config

NAME=jenkins-master
SECRETS_FILE=../${WF}/secrets_${NAME}.yaml
SECRETS_TMP_FILE=../${TMP}/secrets_${NAME}.t.yaml
CERTS_DIR=certs
KEY=id_rsa
KH=known_hosts

IM_ESC=$(sed 's/[\/]/\\&/g' <<<"$GS_IMAGE_BUCKET")

if [ ! -d ${CERTS_DIR} ]; then
	mkdir ${CERTS_DIR}
fi

if [ -f ${CERTS_DIR}/${KEY} ]; then
	echo "SSH key file exists, using it instead of generating a new one"
else
	echo "Generating SSH keys..."
	ssh-keygen -N "" -t rsa -f ${CERTS_DIR}/${KEY} 1>/dev/null
fi

if [ ! -f ${CERTS_DIR}/${KH} ]; then
	echo "Generating known_hosts for ${GIT_CFG_BACKUP_HOST}..."
	ssh-keyscan -H ${GIT_CFG_BACKUP_HOST} > ${CERTS_DIR}/${KH}
fi

echo "Encoding..."
key=`base64 -i ${CERTS_DIR}/${KEY}`
keypub=`base64 -i ${CERTS_DIR}/${KEY}.pub`
kh=`base64 -i ${CERTS_DIR}/${KH}`

echo "Creating secrets file from template..."

sed "s/idrsa: ''/idrsa: '${key}'/; s/idrsapub: ''/idrsapub: '${keypub}'/; s/knownhosts: ''/knownhosts: '${kh}'/" ${SECRETS_TMP_FILE} > ${SECRETS_FILE}

echo "Generating rc_jenkins-master.template.yaml"
sed "s/GS_IMAGE_BUCKET/${IM_ESC}/" ../${TMP}/rc_${NAME}.t.yaml > ../${WF}/rc_${NAME}.yaml

echo "Inserting git url into jenkins scm backup plugin"
GIT_ESC=$(sed 's/[\/]/\\&/g' <<<"$GIT_CFG_BACKUP_REPO")
sed "s/GIT_REPO/${GIT_ESC}/" ../${TMP}/scm-sync-configuration.t.xml > docker/jenkins-master/jenkins/scm-sync-configuration.xml

