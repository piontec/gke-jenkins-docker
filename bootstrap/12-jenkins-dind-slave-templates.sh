#!/bin/bash

source ../etc/config

NAME=jenkins-dind-slave
FILE=../${WF}/rc_${NAME}.yaml
TMP_FILE=../${TMP}/rc_${NAME}.t.yaml

IM_ESC=$(sed 's/[\/]/\\&/g' <<<"$GS_IMAGE_BUCKET")

echo "Inserting slave auth data into rc_jenkins-dind-slave.t.yaml"
sed "s/<JSU>/${JENKINS_SLAVE_USER}/; s/GS_IMAGE_BUCKET/${IM_ESC}/; s/<JSP>/${JENKINS_SLAVE_PASSWORD}/" ${TMP_FILE} > ${FILE}

