#!/bin/bash

./d_11_jenkins_down_net.sh
./d_00_cluster_down.sh

echo "***All scripts completed!***"
echo "*WARNING* This script does not delete persistent disk. If you want to remove them, please execute the following \
commands by hand"
echo "gcloud compute disks delete jenkins-master-home"
