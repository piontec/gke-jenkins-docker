#!/bin/bash

./00-bootstrap-secrets.sh
./01-insert-secrets.sh
./10-jenkins-master-templates.sh
./11-jenkins-master-docker.sh
./12-jenkins-dind-slave-templates.sh
./13-jenkins-dind-slave-docker.sh

