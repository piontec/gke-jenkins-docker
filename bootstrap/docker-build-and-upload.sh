#!/bin/bash -x


NAME=$1
DATE=`date +%Y_%m_%d_%H%M%S`

DIR="docker/${1}"
echo "building docker image form directory ${1}"

source ../etc/config
cd docker/$1 

LATEST="${GS_IMAGE_BUCKET}/${NAME}:latest"
DATETAG="${GS_IMAGE_BUCKET}/${NAME}:${DATE}"
LOCALTAG="local/${NAME}"

echo "Building docker container"
ID=`docker build --pull --rm -q -t ${LOCALTAG} . | egrep "^Successfully\ built\ [0-9a-f]+" | cut -f 3 -d " "`
echo "Built container ID: ${ID}"


echo "tagging containers for GCR"
docker tag -f $ID $LATEST
docker tag -f $ID $DATETAG

echo "Pushing images to GCR"
set -x
gcloud docker push $LATEST
gcloud docker push $DATETAG
set +x

#echo "Removing local image"
#docker rmi -f $ID
#docker rmi -f $LATEST
#docker rmi -f $DATETAG

echo "Container ${NAME} built and uploaded to gcr, url:"
echo "$LATEST"
echo "$DATETAG"

cd ../..
