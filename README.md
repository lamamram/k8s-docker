# cluster KubeSpray + ctrl Kubectl / Helm

## lancement

1. lancement du cluster

  * `vagrant up`
  * question **What to build ?** (Cluster/ctrl/all)
    + CLUSTER: taper `<enter>` (par défaut)

2. lancement du controler jenkins/kubectl/helm
  * `vagrant up`
  * question **What to build ?** (Cluster/ctrl/all)
    + ctrl: écrire `ctrl`

> la valeur `all` lance tout mais plante à cause d'un timeout que je n'ai pas encore dérerminé

## remarque

* quand le jenkins est lancé individuellement: `vagrant ssh jenkins.lan` ne fonctionne plus, car il faudrait tout lancer avec un seul `vagrant up`
* alors vous pouvez charger les `vagrant-helpers.(ps1|sh)` pour powershell / bash
* le script **v_ssh_jenkins** lance un ssh sur le port 2202
  => signifie que c'est la 4ème vms lancée avec Virtualbox
  + 1ère machine: 2222
  + 2ème machine: 2200
  + 3ème machine: 2201
  + 4ème machine: 2202
  => il ne faut pas de machines lancée à côté !!! 
  => ou changer le port dans le script
* même chose pour le **vagrant halt/destroyf jenkin.lan**
  => utiliser virtualbox pour suspendre et détruire
 