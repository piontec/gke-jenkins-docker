#!/bin/bash
set -e

source ../etc/config

echo "Recreating working files based on current config/certs content"
if [ ! -d ../${WF} ]; then
	mkdir ../${WF}
fi

./01-insert-secrets.sh
./10-jenkins-master-templates.sh
./12-jenkins-dind-slave-templates.sh
