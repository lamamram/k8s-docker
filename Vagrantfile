## Toute commande doit-ere exécution dans le répertoire contenant le Dockerfile
# vagrant up
# vagrant halt
# vagrant destroy
# vagrant global-config
#----------------------
# vagrant ssh [NAME|ID]
Vagrant.configure(2) do |config|

  # int = "nom de l'interface réseau connectée au routeur (ip a || ipconfig /all)"
  # ip = "adresse ip disponible sur le sous réseau local (ping pour tester)"
  # cidr = "24 (si masque réseau en 255.255.255.0)"
  int = "Intel(R) Ethernet Connection (7) I219-LM #2"
  range = "192.168.1.3"
  cidr = "24"

  image = "ml-registry/jenkins"

  [
    ["formation.lan", "2048", "2", "#{image}", "#{range}0"],
  ].each do |vmname,mem,cpu,os,ip|
    config.vm.define "#{vmname}" do |machine|

      machine.vm.provider "virtualbox" do |v|
        v.memory = "#{mem}"
        v.cpus = "#{cpu}"
        v.name = "#{vmname}"
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
      machine.vm.box = "#{os}"
      machine.vm.hostname = "#{vmname}"
      # machine.vm.network "public_network"
      machine.vm.network "public_network", bridge: "#{int}",
        ip: "#{ip}",
        netmask: "#{cidr}"
	    machine.ssh.insert_key = false
    end
  end
end
