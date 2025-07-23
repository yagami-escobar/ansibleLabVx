#! /bin/bash

set -euo pipefail

echo "[CONTROL] Install Pkgs Base:"
apt-get update
apt-get install -y sudo vim python3 python3-pip openssh-client sshpass ansible curl iputils-ping net-tools iproute2 tree git


echo "[CONTROL] Create Ansible User:"
useradd -m ansible
echo "ansible:ansible" | chpasswd
usermod -aG sudo ansible
mkdir -p /home/ansible

echo "[CONTROL] Config SSH Home:"
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers


# echo "[CONTROL] Copy EntryPoint ..."
# cp ./scripts/entrypoint.sh /entrypoint.sh
# chmod +x /entrypoint.sh
