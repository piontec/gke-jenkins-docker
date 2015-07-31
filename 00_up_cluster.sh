#!/bin/bash

set -e

source lib/common.sh 
load_config

if [ ! -d ${WF} ]; then
    mkdir ${WF}
fi

TEMPKEY=false

if [ -f "~/.ssh/google_compute_engine" ]
then
    TEMPKEY=true
    echo -n "* Generating a temporary SSH key pair..."
    ssh-keygen -f ~/.ssh/google_compute_engine -t rsa -N '' || error_exit "Error creating key pair"
    echo "done."
fi

cp inputs/* ${WF}/

echo "Setting the configured project name as a default for gcloud"
gcloud config set project ${PROJECT}

echo -n "* Creating Google Container Engine cluster \"${CLUSTER_NAME}\"..."
# Create cluster
gcloud beta container clusters create ${CLUSTER_NAME} \
  --project ${PROJECT} \
  --num-nodes ${NUM_NODES} \
  --machine-type ${MACHINE_TYPE} \
  --scopes ${SCOPES} \
  --disk-size ${DISK_SIZE} \
  --zone ${ZONE} >/dev/null || error_exit "Error creating Google Container Engine cluster"
echo "done."

if [ "$TEMPKEY" = "true" ]
then
  echo -n "Deleting temporary SSH key pair..."
  rm ~/.ssh/google_compute_engine*
  echo "done."
fi

# Make kubectl use new cluster
echo -n "Configuring kubectl to use new gke_${PROJECT}_${ZONE}_${CLUSTER_NAME} cluster..."
kubectl config use-context gke_${PROJECT}_${ZONE}_${CLUSTER_NAME} >/dev/null || error_exit "Error configuring kubectl"
echo "done."

# Wait for API server to become avilable
for i in {1..5}; do kubectl get pods &>/dev/null && break || sleep 2; done

echo -n "Tagging nodes..."
gcloud compute instances list \
  -r "^gke-${CLUSTER_NAME}.*node.*$" \
  | tail -n +2 \
  | cut -f1 -d' ' \
  | xargs -L 1 -I '{}' gcloud compute instances add-tags {} --zone ${ZONE} --tags gke-${CLUSTER_NAME}-node &>/dev/null || error_exit "Error adding tags to nodes"
echo "done."

echo "Cluster is ready"
