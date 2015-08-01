#!/bin/bash

set -e
source lib/common.sh
load_config

# Deploy secrets, replication controllers, and services
echo "Creating persistent disk for jenkins master"
gcloud compute disks create jenkins-master-home --size 10GB || true
echo -n "Deploying services, controllers, and secrets to Google Container Engine..."
deploy ${WF}/secrets_jenkins-proxy.yaml
deploy ${WF}/secrets_jenkins-master.yaml
deploy ${WF}/service_jenkins-proxy.yaml
deploy ${WF}/service_jenkins-master.yaml
deploy ${WF}/rc_jenkins-proxy.yaml
deploy ${WF}/rc_jenkins-master.yaml
deploy ${WF}/rc_jenkins-dind-slave.yaml
echo "done."

echo -n "Waiting for jenkins proxy to be ready..."
while [ -z $proxy ]; do
	proxy=`kubectl describe service srv-jenkins-proxy 2>/dev/null | grep 'LoadBalancer\ Ingress' | cut -f2`
	sleep 1
	echo -n "."
done

echo
echo "Jenkins SSL proxy available under https://${proxy}"
echo "Jenkins dind slave deployed, please *remember* to create account and password for slave user '${JENKINS_SLAVE_USER}' with password '${JENKINS_SLAVE_PASSWORD}' in jenkins!"


