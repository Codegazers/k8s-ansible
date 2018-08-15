#!/bin/bash

set -e
HOST_NAME=$(hostname)
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)
USERNAME="vagrant"
PASSWORD="vagrant"

# sudo sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
# sudo apt-add-repository -y ppa:ansible/ansible
# sudo apt-get update \
# && sudo apt-get install -y \
# ansible \
# git \
# sshpass \
# python-netaddr \
# libssl-dev


# yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -N ""
# HOSTS="10.10.10.11 10.10.10.12 10.10.10.13"
# for host in ${HOSTS}; do
#     sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir -p /root/.ssh"
#     sudo cat /root/.ssh/id_rsa.pub | \
#     sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
# done
#  sshpass -p "vagrant" ssh-copy-id -i /home/${USERNAME}/.ssh/id_rsa.pub vagrant@${host}

yes "/home/${USERNAME}/.ssh/id_rsa" | ssh-keygen -t rsa -N ""
mkdir -p /root/.ssh/
cp /home/${USERNAME}/.ssh/id_rsa* /root/.ssh/
HOSTS="10.10.10.11 10.10.10.12 10.10.10.13"

for host in ${HOSTS}; do
  sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${USERNAME}@${host} "sudo mkdir -p /home/${USERNAME}/.ssh"
  cat /home/${USERNAME}/.ssh/id_rsa.pub | sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${USERNAME}@${host} "sudo tee -a /home/${USERNAME}/.ssh/authorized_keys"
done


cd /vagrant
ansible-playbook site.yaml

