#!/bin/bash
set -e

source lib/common.sh
load_config

echo -n "Creating firewall rules..."

TMP_NAME=`gcloud compute instance-templates list | grep gke-${CLUSTER_NAME} | cut -f1 -d" "`
TAG=`gcloud compute  instance-templates describe ${TMP_NAME} | grep tags -A 2| tail -n 1  | awk 'BEGIN {FS="- ";}{print $2}'`
echo $TAG

## Allow kubernetes nodes to communicate between eachother on TCP 50000 and 8080
gcloud compute firewall-rules create ${CLUSTER_NAME}-jenkins-swarm-internal --allow TCP:50000,TCP:8080 --source-tags ${TAG} --target-tags ${TAG} &>/dev/null || error_exit "Error creating internal firewall rule"
## Allow public access to TCP 80 and 443
gcloud compute firewall-rules create ${CLUSTER_NAME}-jenkins-web-public --allow TCP:80,TCP:443,TCP:8888 --source-ranges 0.0.0.0/0 --target-tags ${TAG} &>/dev/null || error_exit "Error creating public firewall rule"
echo "done."
