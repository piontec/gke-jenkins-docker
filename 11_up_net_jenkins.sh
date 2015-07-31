#!/bin/bash
set -e

source lib/common.sh
load_config

echo -n "Creating firewall rules..."

# Check for cluster name as first (and only) arg
INSTANCE_NAME=`gcloud compute instances list | grep ${CLUSTER_NAME} | cut -f1 -d" " | head -n 1`
NODE_TAG=`gcloud compute instances describe ${INSTANCE_NAME} | grep "tags" -A 4 | tail -n 1 | cut -f4 -d" "`

## Allow kubernetes nodes to communicate between eachother on TCP 50000 and 8080
gcloud compute firewall-rules create ${CLUSTER_NAME}-jenkins-swarm-internal --allow TCP:50000,TCP:8080 --source-tags ${NODE_TAG} --target-tags ${NODE_TAG} &>/dev/null || error_exit "Error creating internal firewall rule"
## Allow public access to TCP 80 and 443
gcloud compute firewall-rules create ${CLUSTER_NAME}-jenkins-web-public --allow TCP:80,TCP:443 --source-ranges 0.0.0.0/0 --target-tags ${NODE_TAG} &>/dev/null || error_exit "Error creating public firewall rule"
echo "done."
