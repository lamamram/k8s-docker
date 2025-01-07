# multistaging build
# 1. j'ai besoin de curl pour mon build ou mon healthcheck
# 2. au lieu de pourir mon image de build avec un apt-get
# 3. on va utiliser un utilitaire "curl-static" envoyé depuis une autre image
#    => d'une image intermédiaire "sidecar"
# STAGE
FROM shakefu/curl-static AS curl

# RUN make ... > binaire

# pour faire une image de distro custom (sans base)
# FROM scratch
FROM httpd:2.4

# labels/tags clé=valeur
LABEL author="matt"
LABEL created_at="2024-12-17"
LABEL stack="java"
LABEL stack.version="1.0"

## rapatrier l'utilitaire "curl-static" => curl devient standalone (un seul binaire)
# src: /usr/local/bin/curl depuis l'image "curl" // dst: /usr/local/bin/curl sur l'image httpd 
COPY --from=curl /usr/local/bin/curl /usr/local/bin/curl 

## injection du fichier de conf dans l'image
COPY httpd.conf /usr/local/apache2/conf/

## créer le dossier sites dans conf/
RUN mkdir /usr/local/apache2/conf/sites

COPY java_app.conf /usr/local/apache2/conf/sites/

## officialiser/déclarer les ports sur lesquels le processus central de l'image écoute
## cette information peut être VRAIE 80 ou FAUSSE 443
EXPOSE 80 443

## lancement de l'image
## 1/ ENTRYPOINT: commande non substituable par une commande en paramètre du docker run
## ENTRYPOINT: il faut l'écrire avec une liste JSON
## ENTRYPOINT [ "httpd", "-D", "FOREGROUND" ]

## 2/ ENTRYPOINT + CMD
## ENTRYPOINT [ "httpd" ]
## CMD: commande substituable par une commande en paramètre du docker run
## CMD: il faut l'écrire avec une liste JSON
## CMD ["-D", "FOREGROUND"]

## 3/ CMD
CMD [ "httpd", "-D", "FOREGROUND" ]

# check périodique (sans retries)
HEALTHCHECK \
            --start-period=3s \
            --timeout=5s \
            --interval=10s \
            CMD curl http://127.0.0.1:80


