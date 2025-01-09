IP_CPANE=$(cat /etc/hosts | grep cpane | awk '{print $1}')

prepare_kubespray(){

    echo
    echo "## 1. Git clone kubepsray"
    git clone https://github.com/kubernetes-sigs/kubespray.git
    chown -R vagrant:vagrant /home/vagrant/kubespray

    echo
    echo "## 2. Install requirements"
    ## installation python d'ansible
    ## ajout d'un environnement virtuel:
    #   - dossier qui centralise les binaires (python3, pip3) et les dépendances
    #   - création du dossier venv
    #   - activation du venv: redirection du terminal sur les binaires (détournement du PATH)
    python3 -m venv venv
    source ./venv/bin/activate
    # installtion des paquets python nécéssaires à ansible dans le venv
    pip3 install --quiet -r kubespray/requirements.txt

    echo
    echo "## 3. ANSIBLE | copy sample inventory"
    cp -rfp kubespray/inventory/sample kubespray/inventory/mycluster

    echo
    echo "## 4. ANSIBLE | change inventory"
    cat /etc/hosts | grep cpane | awk '{print $2" ansible_host="$1" ip="$1" etcd_member_name=etcd"NR}'>kubespray/inventory/mycluster/inventory.ini
    cat /etc/hosts | grep worker | awk '{print $2" ansible_host="$1" ip="$1}'>>kubespray/inventory/mycluster/inventory.ini

    echo "[kube_control_plane]">>kubespray/inventory/mycluster/inventory.ini
    cat /etc/hosts | grep cpane | awk '{print $2}'>>kubespray/inventory/mycluster/inventory.ini

    echo "[etcd]">>kubespray/inventory/mycluster/inventory.ini
    cat /etc/hosts | grep cpane | awk '{print $2}'>>kubespray/inventory/mycluster/inventory.ini

    echo "[kube_node]">>kubespray/inventory/mycluster/inventory.ini
    cat /etc/hosts | grep worker | awk '{print $2}'>>kubespray/inventory/mycluster/inventory.ini

    echo "[calico_rr]">>kubespray/inventory/mycluster/inventory.ini
    echo "[etcd:children]">>kubespray/inventory/mycluster/inventory.ini
    echo "kube_control_plane">>kubespray/inventory/mycluster/inventory.ini
    echo "kube_node">>kubespray/inventory/mycluster/inventory.ini
    echo "calico_rr">>kubespray/inventory/mycluster/inventory.ini


    echo
    echo "## 5.x ANSIBLE | active external LB"
    sed -i s/"## apiserver_loadbalancer_domain_name: \"elb.some.domain\""/"apiserver_loadbalancer_domain_name: \"autoelb.lan\""/g kubespray/inventory/mycluster/group_vars/all/all.yml
    sed -i s/"# loadbalancer_apiserver:"/"loadbalancer_apiserver:"/g kubespray/inventory/mycluster/group_vars/all/all.yml
    sed -i s/"#   port: 1234"/"  port: 6443"/g kubespray/inventory/mycluster/group_vars/all/all.yml
}

create_ssh_for_kubespray(){

    echo 
    echo "## 6. SSH | ssh private key and push public key"
    sudo -u vagrant bash -c "ssh-keygen -b 2048 -t rsa -f .ssh/id_rsa -q -N ''"
    for srv in $(cat /etc/hosts | grep -E "cpane|worker" | awk '{print $2}');do
    cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$srv -T 'tee -a >> /home/vagrant/.ssh/authorized_keys'
    done
}

run_kubespray(){
    echo
    echo "## 7. ANSIBLE | Run kubepsray"
    ## EXPLICATIONS
    # 1/ sudo su - vagrant: permet de s'assurer que la commande ansible va être lancée par l'utilisateur vagrant du contrôleur
    # 2/ bash -c: quand on arrive dans le compte vagrant on invoque un bash, pour être sûr d'être dans un bash
    # 3/ source .../activate: nouveau bash donc il faut réactiver le venv sinon le bash ne voit pas les paquets ansible !!!
    # 4/ cd kubespray: pour activer la configuration ansible.cfg
    #    - algorithme de découverte de ansible.cfg: ./ansible.cfg,~/.config/ansible.cfg
    #    - algorithme de découverte des rôles sans ansible.cfg: ./playbooks/roles : FALSE !!!
    #    - avec ansible.cfg: les rôles sont à la racine de kubespray
    # 5/ ansible-playbook [] cluster.yml : lancement du playbook central
    #    - i ... : on demande explicitement l'inventaire à cause du ansible.cfg (.ini ignored)
    #    - b: BECOME: je demande un augmentation de privilège: pour les tâches qui nécessitent le SUDO
    #      + cas simple car on a un compte vagrant avec sudo sans mdp => sinon -e "ansible_become_pass=$ANSIBLE_SUDO_PASS"
    #    - -u vagrant: compte vagrant sur les cibles (cluster) 
    sudo su - vagrant bash -c "source ./venv/bin/activate;cd kubespray;ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/mycluster/inventory.ini -b -u vagrant cluster.yml"
}

install_kubectl(){
    KUBE_CTL_VERSION="v1.30"
    echo
    echo "## 8. KUBECTL | Install"
    apt-get update && apt-get install -y apt-transport-https curl gnupg2
    curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBE_CTL_VERSION/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBE_CTL_VERSION/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
    apt-get update -qq 2>&1 >/dev/null
    apt-get install -qq -y kubectl 2>&1 >/dev/null
    
    ## installation du context k8s: ensemble des informations pour connecter le cluster
    mkdir -p /home/vagrant/.kube
    chown -R vagrant /home/vagrant/.kube
    
    echo
    echo "## 9. KUBECTL | copy context with cert"
    ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa vagrant@${IP_CPANE} "sudo cat /etc/kubernetes/admin.conf" >/home/vagrant/.kube/config
}

prepare_kubespray
create_ssh_for_kubespray
run_kubespray
install_kubectl


