#!/bin/bash

#### SUPPRESSIONS #######
# test de l'existence des conteneurs si c'est vrai je supprime les conteneurs
# -q: affiche uniquement les identifiants
[[ -z $(docker ps -aq --filter name="stack-php-*") ]] || docker rm -f $(docker ps -aq -f "name=stack-php-*")

# -f ici, rend la commande "non-error" si le réseau n'existe pas !!!
docker network rm -f stack-php

#### RESEAU CUSTOM (pour la résolution de nom auto. avec les noms des conteneurs)

docker network create \
       --driver bridge \
       --subnet 172.18.0.0/24 \
       --gateway 172.18.0.1 \
       stack-php

#### CONTENEURS

# -e MARIADB_USER=test \
# -e MARIADB_PASSWORD=roottoor \
# -e MARIADB_DATABASE=test \
# -e MARIADB_ROOT_PASSWORD=roottoor \

docker run \
       --name stack-php-db \
       -d --restart unless-stopped \
       --env-file .env \
       --net stack-php \
       -v ./mariadb-init.sql:/docker-entrypoint-initdb.d/mariadb-init.sql:ro \
       -v db_data:/var/lib/mysql \
       mariadb:lts-ubi


docker run \
       --name stack-php-fpm \
       -d --restart unless-stopped \
       --net stack-php \
       -v ./index.php:/srv/index.php:ro \
       bitnami/php-fpm:8.4-debian-12

# remplacé par le -v bind mount: attention il faut spécifier la source comme un chemin
# docker cp index.php stack-php-fpm:/srv/index.php

docker run \
       --name stack-php-nginx \
       -d --restart unless-stopped \
       --net stack-php \
       -p 8080:80 \
       -v ./vhost.conf:/etc/nginx/conf.d/vhost.conf:ro \
       nginx:1.27.3-bookworm-perl

# docker cp vhost.conf stack-php-nginx:/etc/nginx/conf.d/vhost.conf
# rechargement de la conf nginx en rédémarrant le conteneur !!
# docker restart stack-php-nginx

