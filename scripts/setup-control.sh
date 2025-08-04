#! /bin/bash
set -euo pipefail

echo "[CONTROL] Update Apt ..."
apt-get update -y

echo "[CONTROL] Install Pkgs ..."
apt-get install -y \
  sudo \
  vim \
  python3 \
  python3-pip \
  pymysql \
  openssh-client \
  sshpass \
  ansible \
  curl \
  iputils-ping \
  net-tools \
  iproute2 \
  tree \
  git

# Instalar PyMySQL globalmente
pip3 install PyMySQL


echo "[CONTROL] Create && Config User(Ansible):"
useradd -m ansible
echo "ansible:ansible" | chpasswd
usermod -aG sudo ansible
mkdir -p /home/ansible
chsh -s /bin/bash ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo "[CONTROL] Config SSH Home:"
mkdir -p /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh


echo "[CONTROL] Generate SSH Key for Ansible:"
sudo -u ansible ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""

echo "[CONTROL] Enable password authentication:"
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf || true
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "[CONTROL] Add managed nodes to /etc/hosts:"
cat<<EOF >> /etc/hosts
192.168.56.11 node1
192.168.56.12 node2
192.168.56.13 node3
EOF

echo "[CONTROL] Copy SSH Key to Managed Nodes:"
NODES=(node1 node2 node3)
for node in "${NODES[@]}"; do
    sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i /home/ansible/.ssh/id_rsa.pub ansible@$node
done

# -------------------------------
# DOCKER ENGINE
# -------------------------------

echo "[CONTROL] Install Docker Engine:"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

ARCH=$(dpkg --print-architecture)
RELEASE=$(lsb_release -cs)

echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $RELEASE stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ansible