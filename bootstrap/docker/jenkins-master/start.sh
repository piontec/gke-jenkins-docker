#! /bin/bash

JH=/var/jenkins_home
SSH_DIR=${JH}/.ssh/

if [ ! -d ${SSH_DIR} ]; then
	mkdir ${SSH_DIR}
fi

cp /root/.gitconfig ${JH}/
cp /etc/secrets/idrsa ${SSH_DIR}/id_rsa
cp /etc/secrets/idrsapub ${SSH_DIR}/id_rsa.pub
cp /etc/secrets/knownhosts ${SSH_DIR}/known_hosts
chmod 400 ${SSH_DIR}/id_rsa
chmod 644 ${SSH_DIR}/id_rsa.pub
chmod 644 ${SSH_DIR}/known_hosts

chown -R jenkins.jenkins ${JH}

su jenkins -c '/usr/local/bin/jenkins.sh "$@"'
