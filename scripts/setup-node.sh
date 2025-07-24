#! /bin/bash

set -euo pipefail

echo "[NODE] Install Pkgs Base:"
apt-get update
apt-get install -y sudo vim python3 python3-pip openssh-server curl iputils-ping net-tools iproute2 tree

echo "[NODE] Create Ansible User"
useradd -m ansible
echo "ansible:ansible" | chpasswd
usermod -aG sudo ansible

echo "[NODE] Config SSH Home:"
mkdir -p /var/run/sshd
mkdir -p /home/ansible/.ssh
touch /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
chsh -s /bin/bash ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo "[NODE] Add control to /etc/hosts"
cat<<EOF >> /etc/hosts
192.168.56.10 control
EOF