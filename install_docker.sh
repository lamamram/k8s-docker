#!/bin/bash

# vérification de l'uid (identifiant utilisateur) qui lance le script
if [ "$(id -u)" -ne 0 ]; then
  echo "lancer avec sudo !!!"
  exit 1
fi

which docker
ret=$?
if [ $ret -eq 0 ]; then
  exit 0
fi

# DISTRO=$(cat /etc/os-release | awk -F '=' '$1 == "ID" { print $2 }')
# CODENAME=$(cat /etc/os-release | awk -F '=' '$1 == "VERSION_CODENAME" { print $2 }')

# génération du cachec apt
apt-get update -q

# install des prérequis (-y confirme, -q diminue l'affichage en console)
apt-get install -yq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# distro=$(echo "$(lsb_release -is)" | awk '{print tolower($0)}')
distro=$(lsb_release -is)

# téléchargement et install de la clé d'authentification des paquets
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${distro,,}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# ajout du dépôt docker qui contient les paquets docker à apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro,,} \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# regénénrer le cache apt pour tenir compte du nouveau dépôt
apt-get update -q

# install des paquets docker
apt-get install -yq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

cat <<EOF > /etc/docker/daemon.json
{
  "insecure-registries": ["127.0.0.1:443","formation.lan:443"]
}
EOF

systemctl restart docker

# ajout de l'utilisateur vagrant au groupe docker 
# autorisé à exécuter des commandes docker sans sudo
usermod -aG docker vagrant




