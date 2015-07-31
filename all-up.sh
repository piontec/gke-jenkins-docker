#!/bin/bash

./00_up_cluster.sh
./10_up_jenkins.sh
./11_up_net_jenkins.sh

rm ${WF}/*

echo "***All scripts completed!***"
