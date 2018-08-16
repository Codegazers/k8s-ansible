#!/bin/bash

set -e
HOSTS="$@"
HOST_NAME=$(hostname)
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)
USERNAME="vagrant"
PASSWORD="vagrant"


yes "/home/${USERNAME}/.ssh/id_rsa" | ssh-keygen -t rsa -N ""
mkdir -p /root/.ssh/
cp /home/${USERNAME}/.ssh/id_rsa* /root/.ssh/

for host in ${HOSTS}; do
  sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${USERNAME}@${host} "sudo mkdir -p /home/${USERNAME}/.ssh"
  cat /home/${USERNAME}/.ssh/id_rsa.pub | sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${USERNAME}@${host} "sudo tee -a /home/${USERNAME}/.ssh/authorized_keys"
done

cd /vagrant
ansible-playbook site.yaml

