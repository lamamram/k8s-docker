# TP sur kubespray

## Exploration

1. checker l'install depuis le controller **formation.lan**
   * `k get nodes`
   * `k cluster-info`
   * `k get pod -A`, à travers tous les namespaces
   * `k get ns`, ns => namespace

2. créer un premier pod
   * `k run <name> --image <image:tag> -- <cmd>`
   * `k run busy --image busybox -- sleep infinity`
   * checker: `k get pod <name> -o wide|yaml|jsonpath '{{ .xxxx.xxx[] }}'`
   * checker: `k get describe pod <name>`
   * checker la ressource (doc): `k explain pod`
   * checker dans le pod: `k exec -it busy -- /bin/bash`

## IaC POD

1. Manifeste

   * dry-run(s)
     + **client**: command not run && apiserver not validated
     + **server**: command not run && apiserver validated (error possible)
     + **none**: command run && apiserver validated but output

   * générer un manifester (YAML) `k run busy --image busybox --dry-run=client -o yaml > /vagrant/k8s/busy.yml`
   * retravailler/renommer le manifeste 
   * et ensuite appliquer depuis le manifeste `k apply -f /vagrant/k8s/busy-dual.yml`

2. plusieurs conteneurs

   * avec plusieurs conteneur dans un pod, distinguer un conteneur
   * `k logs busy-dual -c web`
   ```bash
   k exec -it busy-dual -c busy -- /bin/sh
   # wget -O - http://localhost:80
   # les 2 conteneurs partagent le namespace "net" en particulier les ports
   ```
   

3. volumes de type emptyDir
   
   ```bash
   k exec -it busy-dual -c busy -- /bin/sh
   # echo "content" > /mnt/fic
   ...
   k exec -it busy-dual -c web -- /bin/sh
   # cat /mnt/fic
   ```

## Deploiement: Deployment

1. génération

   ```bash
   k create deployment sample-java \
     --image formation.lan:443/stack-java-httpd:1.0 \
     --image formation.lan:443/stack-java-tomcat:1.0 \
     --dry-run=client -o yaml > /vagrant/k8s/sample-java-dpl.yml
   ```

2. création du namespace (partition "hermitique" du cluster k8s )

   * `k create ns stack-java --dry-run=client -o yaml > /vagrant/k8s/stack-java-ns.yml`

3. application du déploiement dans le namespace "stack-java"
   * `k apply -n stack-java -f /vagrant/k8s/sample-java-dpl.yml`
   * MIEUX: ajouter le namespace dans le manifeste

   * checker: `k get -n stack-java deployments.apps,pod -o wide`

## cas réél: l'application sample-java

### utiliser les images docker locales dans les noeud

* k8s n'utilise pas nativement le registre local d'images docker, 
  mais son propre registre via `crictl`

```bash
# export import docker / export cri (k8s)
docker save formation.lan:443/stack-java-httpd:1.0 -o httpd.tar
sudo ctr -n=k8s.io images import httpd.tar
sudo crictl images | grep httpd
```

### mieux: connecter le déploiement au registre à la volée via un Secret

```bash
k create secret generic regcred \
  --from-file=.dockerconfigjson=/home/vagrant/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --dry-run=client -o yaml > /vagrant/k8s/registry-secret.yml
```
* REM: le fichier `/home/vagrant/.docker/config.json` contient un secret encodé en base64 => pas CHIFFRE
  => utiliser le `credStore` Docker
* REM2: le secret en yml est encodé en base64 => pas CHIFFRE
  => utiliser les ressources Encryption (etcd, api ...)

* REM3: configurer un accès insecure au registre dans k8S
  + exécuter le script `/home/k8s/insecure_containerd_config.sh`
  + dans les noeuds

### mise en réseau

* exposition au sens k8s != au sens docker

* ajouter un **service** à un déploiement

```bash
k expose -n stack-java deployment sample-java \
--port 80 \
--target-port 8080 \
--dry-run=client -o yaml > /vagrant/k8s/sample-java-svc.yml
```

* test: `k exec -n stack-java busy -- wget -O - http://sample-java`


* test (FQDN from outside): `k exec busy -- nslookup sample-java.stack-java.svc.cluster.local`





