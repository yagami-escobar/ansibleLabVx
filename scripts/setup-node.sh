#! /bin/bash

set -euo pipefail


echo "[NODE] Update Apt ..."
apt-get update -y

echo "[NODE] Install Pkgs ..."
apt-get install -y \
  sudo \
  vim \
  python3 \
  python3-pip \
  openssh-server \
  curl \
  iputils-ping \
  net-tools \
  iproute2 \
  tree \
  git

# Instalar PyMySQL globalmente
pip3 install PyMySQL


echo "[NODE] Create Ansible User"
useradd -m ansible
echo "ansible:ansible" | chpasswd
usermod -aG sudo ansible
mkdir -p /home/ansible
chsh -s /bin/bash ansible


echo "[NODE] Config SSH Home:"
mkdir -p /var/run/sshd
mkdir -p /home/ansible/.ssh
touch /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys

echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo "[NODE] Enable password authentication:"
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf || true
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "[NODE] Add control to /etc/hosts"
cat<<EOF >> /etc/hosts
192.168.56.10 control
EOF