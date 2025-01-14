FROM debian:12-slim

LABEL author="matt"
LABEL created_at="2025-01-07"
LABEL stack="java"
LABEL stack.version="1.1"

# REMARQUE: ces variables d'environnement ne peuvent pas être modifiées 
#          : qu'au moment du docker run --env HOME 
ENV HOME=/opt/tomcat/webapps

ARG TOMCAT_VERSION_MAJOR=9
ARG TOMCAT_VERSION_FULL

## BEST PRACTICE: couches qui changent peu et lentes en premier
## BEST PRACTICE: enchaîner avec "&&" les RUN qui créént / modifient / suppriment les mêmes objets
## BEST PRACTICE: minimiser les couches (&& \)
## BEST PRACTICE: utiliser des chemins absolus
## BEST PRACTICE: on a pas besoin de créer l'archive tomcat en tant que fichier
##              : puisque curl et tar peuvent fonctionner en flux ( | )
RUN mkdir /opt/tomcat && \
    apt-get update -q && apt-get install -yq openjdk-17-jre-headless curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl https://downloads.apache.org/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz | \
    tar -xzv -C /opt/tomcat --strip-components=1 && \
    useradd -M -d /opt/tomcat -U tomcat && \
    curl https://tomcat.apache.org/tomcat-10.1-doc/appdev/sample/sample.war -o /opt/tomcat/webapps/sample.war && \
    chown -R tomcat:tomcat /opt/tomcat

WORKDIR ${HOME}

USER tomcat

## utilisable avec le docker run --volumes-from <ctn>
VOLUME [ "/opt/tomcat/webapps" ]

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run" ]

# après le lancement du conteneur lié à cette image (docker run)
# 1/ on va attendre 3s (start-period)
# 2/ on exécute le CMD du HEALTHCHECK qui DOIT PROUVER que le conteneur est lancé correctement
# 3.1/ soit le CMD du HEALTHCHECK termine avant 5s (le timeout) avec un code de retour 0 (SUCESS)
#      => le STATUS du docker ps spécifie "healthy"
# 3.2/ soit le CMD du HEALTHCHECK termine avant 5s (le timeout) avec un code de retour NON-0 (FAIL)
#      => on décrémente le paramètre retries (3) => on peut réesssayer 3x
#      => on attend 2s (interval) pour réessayer
# 3.3/ soit le CMD du HEALTHCHECK termine APRES le timeout => retry + interval
# Dans tous les cas si le CMD du HEALTHCHECK finit en non-0 (FAIL) alors
#      => le STATUS du docker ps spécifie "unhealthy" 

## WARNING: CMD du HEALTHCHECK ne fonctionne pas avec une liste de JSON ["" , ""]
HEALTHCHECK \
            --start-period=3s \
            --timeout=5s \
            --retries=3 \
            --interval=2s \
            CMD grep "Server startup" /opt/tomcat/logs/catalina.*.log
