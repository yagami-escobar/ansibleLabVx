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
mkdir -p /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers



echo "[CONTROL] Generate SSH Key for Ansible:"
sudo -u ansible ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""

echo "[CONTROL] Copy SSH Key to Managed Nodes:"
for ip in 192.168.56.11 192.168.56.12; do
    sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no ansible@$ip
done

echo "[CONTROL] Add managed nods to /etc/hosts:"
cat<<EOF >> /etc/hosts
192.168.56.11 node1
192.168.56.12 node2
EOF