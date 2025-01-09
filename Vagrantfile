## Toute commande doit-ere exécution dans le répertoire contenant le Dockerfile
# vagrant up
# vagrant halt
# vagrant destroy
# vagrant global-config
#----------------------
# vagrant ssh [NAME|ID]
Vagrant.configure(2) do |config|

  ## VARIABLES

  # int = "nom de l'interface réseau connectée au routeur (ip a || ipconfig /all)"
  # ip = "adresse ip disponible sur le sous réseau local (ping pour tester)"
  # cidr = "24 (si masque réseau en 255.255.255.0)"
  int = "Intel(R) Ethernet Connection (7) I219-LM #2"
  range = "192.168.1.3"
  cidr = "24"
  
  etcHosts = ""
  image_ctrl = "ml-registry/jenkins"
  image_cluster = "bento/ubuntu-22.04"

  # paquets et configuration pour les 4 machines
  common = <<-SHELL
  sudo apt update -qq 2>&1 >/dev/null
  sudo apt install -y -qq git vim tree net-tools telnet git python3-pip python3-venv sshpass 2>&1 >/dev/null
  sudo echo "autocmd filetype yaml setlocal ai ts=2 sw=2 et" > /home/vagrant/.vimrc
  sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  SHELL

  # prérequis RAM > 1.6 GO, CPU >= 1
  NODES = [
    { :hostname => "cpane.lan", :ip => "#{range}2", :mem => 2048, :cpus => 2 },
    { :hostname => "worker1.lan", :ip => "#{range}3", :mem => 1800, :cpus => 1 },
    { :hostname => "worker2.lan", :ip => "#{range}4", :mem => 1800, :cpus => 1 },
  ]

  # collecte des dns locaux dans les 4 machines
  NODES.each do |node|
    etcHosts += "echo '" + node[:ip] + "   " + node[:hostname] + " autoelb.lan' >> /etc/hosts" + "\n"
  end
  etcHosts += "echo '" + "#{range}1" + " " + "formation.lan" + " autoelb.lan' >> /etc/hosts" + "\n"

  ## MAIN

  # CONTROLLER
  [
    ["formation.lan", "#{range}1", "2048", "2"],
  ].each do |hostname,ip,mem,cpus|
    
    config.vm.define "#{hostname}" do |machine|

      machine.vm.provider "virtualbox" do |v|
        v.name = "#{hostname}"
        v.memory = "#{mem}"
        v.cpus = "#{cpus}"
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
      machine.vm.hostname = "#{hostname}"
      machine.vm.box = "#{image_ctrl}"
      # machine.vm.network "public_network"
      machine.vm.network "public_network", bridge: "#{int}",
        ip: "#{ip}",
        netmask: "#{cidr}"
        machine.ssh.insert_key = false
      ## provisioners
      machine.vm.provision "shell", inline: etcHosts
      machine.vm.provision "shell", inline: common
      machine.vm.provision "install-kubespray",
        type: "shell", path: "install_k8s.sh"
    end
  end

  # run installation
  NODES.each do |node|
    config.vm.define node[:hostname] do |machine|

      machine.vm.provider "virtualbox" do |v|
        v.customize [ "modifyvm", :id, "--cpus", node[:cpus] ]
        v.customize [ "modifyvm", :id, "--memory", node[:mem] ]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        # v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        v.customize ["modifyvm", :id, "--name", node[:hostname] ]
      end
      machine.vm.hostname = node[:hostname]
      machine.vm.box = "#{image_cluster}"
      # machine.vm.network "private_network", ip: node[:ip]
      machine.vm.network "public_network", bridge: "#{int}",
        ip: node[:ip],
        netmask: "#{cidr}"
        machine.ssh.insert_key = false

      # for all
      machine.vm.provision "shell", inline: etcHosts
      machine.vm.provision "shell", inline: common
      machine.vm.provision "shell", path: "install_docker.sh"
    end
  end
end
