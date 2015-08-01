#!/bin/bash

source "etc/config"

# Delete firewall rules
echo "Deleting firewall rules"
gcloud compute firewall-rules delete --quiet ${CLUSTER_NAME}-jenkins-swarm-internal
gcloud compute firewall-rules delete --quiet ${CLUSTER_NAME}-jenkins-web-public
