#!/bin/bash

# Delete services

source lib/common.sh 
load_config

# Deploy secrets, replication controllers, and services
echo -n "Deleting services, controllers, and secrets to Google Container Engine..."
delete ${WF}/secrets_jenkins-proxy.yaml
delete ${WF}/secrets_jenkins-master.yaml
delete ${WF}/service_jenkins-proxy.yaml
delete ${WF}/service_jenkins-master.yaml
delete ${WF}/rc_jenkins-proxy.yaml
delete ${WF}/rc_jenkins-master.yaml
delete ${WF}/rc_jenkins-dind-slave.yaml
echo "done."

echo "Deleted jenkins services"
