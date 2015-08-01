#!/bin/bash

source "etc/config"

# Delete cluster
echo "Deleting container cluster"
gcloud beta container clusters delete --quiet ${CLUSTER_NAME} --zone ${ZONE}


