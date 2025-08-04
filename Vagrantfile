Vagrant.configure("2") do |config|
  # Box base
  config.vm.box = "ubuntu/jammy64"

  # Nodo gestionado 1
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.56.11"
    node1.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node1.vm.provision "shell", path: "scripts/setup-node.sh"
    node1.vm.provision "shell", inline: <<-SHELL
      echo 'exec sudo -i -u ansible' >> /home/vagrant/.bashrc
    SHELL
  end

  # Nodo gestionado 2
  config.vm.define "node2" do |node2|
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: "192.168.56.12"
    node2.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 1
    end
    node2.vm.provision "shell", path: "scripts/setup-node.sh"
    node2.vm.provision "shell", inline: <<-SHELL
      echo 'exec sudo -i -u ansible' >> /home/vagrant/.bashrc
    SHELL
  end
  
  # Nodo gestionado 3
  config.vm.define "node3" do |node3|
    node3.vm.hostname = "node3"
    node3.vm.network "private_network", ip: "192.168.56.13"
    node3.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 1
    end
    node3.vm.provision "shell", path: "scripts/setup-node.sh"
    node3.vm.provision "shell", inline: <<-SHELL
      echo 'exec sudo -i -u ansible' >> /home/vagrant/.bashrc
    SHELL
  end

  # Nodo de control
  config.vm.define "control" do |control|
    control.vm.hostname = "control"
    control.vm.network "private_network", ip: "192.168.56.10"
    control.vm.provider "virtualbox" do |vb|
      vb.memory = 3072
      vb.cpus = 2
    end
    control.vm.provision "shell", path: "scripts/setup-control.sh"
    control.vm.provision "shell", inline: <<-SHELL
      echo 'exec sudo -i -u ansible' >> /home/vagrant/.bashrc
    SHELL
  end
end