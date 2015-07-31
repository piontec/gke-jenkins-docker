#!/bin/bash

# Delete services

source etc/config

function error_exit
{
    echo "$1" 1>&2
    exit 1
}


function delete
{
	kubectl delete -f $1 >/dev/null || error_exit "Error deleteing ${1}"
}

# Deploy secrets, replication controllers, and services
echo -n "* Deploying services, controllers, and secrets to Google Container Engine..."
delete ${WF}/secrets_jenkins-proxy.yaml
delete ${WF}/secrets_jenkins-master.yaml
delete ${WF}/service_jenkins-proxy.yaml
delete ${WF}/service_jenkins-master.yaml
delete ${WF}/rc_jenkins-proxy.yaml
delete ${WF}/rc_jenkins-master.yaml
delete ${WF}/rc_jenkins-dind-slave.yaml
echo "done."

echo "Deleted jenkins services"
