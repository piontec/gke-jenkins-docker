#!/bin/bash
set -e

proxy=`kubectl describe service/srv-jenkins-proxy 2>/dev/null | grep 'LoadBalancer\ Ingress' | cut -f2`
echo "Jenkins SSL proxy available under https://${proxy}"
