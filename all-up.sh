#!/bin/bash

source lib/common.sh 
load_config

./00_up_cluster.sh
./10_up_jenkins.sh
./11_up_net_jenkins.sh

rm ${WF}/*.yaml

echo "***All scripts completed!***"
