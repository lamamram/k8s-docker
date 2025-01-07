## nous allons utiliser une image debian12
FROM debian:12-slim

## documenter l'image
LABEL author="matt"
LABEL created_at="2025-01-06"
LABEL stack="java"
LABEL stack.version="1.0"

ENV USER=tomcat

ARG TOMCAT_VERSION_MAJOR=9
ARG TOMCAT_VERSION_FULL

## installer java (apt-get)
## et nettoyer le dépôt apt après
## ajouter un dossier /opt/tomcat
## injecter le fichier https://downloads.apache.org/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz dans ce dossier
## décomprésser dans ce dossier sans dossier intermédiaire 
## et supprimer l'archive
# ADD https://downloads.apache.org/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz /opt/tomcat
## ajouter un utilisateur tomcat avec le dossier /opt/tomcat comme home et le groupe propriétairers /opt/tomcat/
## télécharger l'application sample https://tomcat.apache.org/tomcat-10.1-doc/appdev/sample/sample.war dans le dossier /opt/tomcat/webapps 
## spécifier le propriétaire et groupe à tomcat 
RUN apt-get update -q && apt-get install -y -q openjdk-17-jre-headless curl && \
    mkdir /opt/tomcat && \
    curl https://downloads.apache.org/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz | \
    tar -xvz -C /opt/tomcat --strip-components=1 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -d /opt/tomcat -U tomcat && \
    curl https://tomcat.apache.org/tomcat-10.1-doc/appdev/sample/sample.war -o /opt/tomcat/webapps/sample.war && \
    chown -R tomcat:tomcat /opt/tomcat

## spécifier le dossier dans lequel on arrive dans le conteneur
WORKDIR /opt/tomcat/webapps

## changer l'utilisateur à tomcat quand on exécute un conteneur
USER ${USER}

## persister le dossier home pour accéder ou sauvegarder les apps
VOLUME [ "/opt/tomcat/webapps" ]

## pour communiquer avec httpd avec le port par défaut de tomcat  ???
EXPOSE 8080

## exécuter de manière dynamique (avec substitution) le binaire en foreground catalina.sh vs startup.sh ???
## et ajouter la sous commande pour lancer en one shot run ou start ???
CMD [ "/opt/tomcat/bin/catalina.sh", "run" ]


HEALTHCHECK \
            --start-period=3s \
            --timeout=10s \
            --retries=3 \
            --interval=3s \
            CMD grep "Server startup" /opt/tomcat/logs/catalina.*.log