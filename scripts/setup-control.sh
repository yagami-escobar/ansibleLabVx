#! /bin/bash
set -euo pipefail

echo "[CONTROL] Install Pkgs Base:"
apt-get update
apt-get install -y sudo vim python3 python3-pip openssh-client sshpass ansible curl iputils-ping net-tools iproute2 tree git


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

echo "[CONTROL] Copy SSH Key to Managed Nodes:"
for ip in 192.168.56.11 192.168.56.12; do
    sshpass -p "ansible" scp ansible@control /home/ansible/.ssh/id_rsa.pub ansible@$ip:/home/ansible/.ssh/ansible.pub
    sshpass -p "ansible" ssh -o StrictHostKeyChecking=no ansible@$ip "cat ~/.ssh/ansible.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm -fv ~/.ssh/ansible.pub"
done

echo "[CONTROL] Add managed nodes to /etc/hosts:"
cat<<EOF >> /etc/hosts
192.168.56.11 node1
192.168.56.12 node2
EOF