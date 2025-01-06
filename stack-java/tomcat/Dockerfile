## nous allons utiliser une image debian12
FROM debian:12-slim

## documenter l'image
LABEL author="matt"
LABEL created_at="2025-01-06"
LABEL stack="java"
LABEL stack.version="1.0"

## ajouter un dossier /opt/tomcat
## injecter le fichier https://downloads.apache.org/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz dans ce dossier
## décomprésser dans ce dossier sans dossier intermédiaire 
## et supprimer l'archive
# ADD https://downloads.apache.org/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz /opt/tomcat
RUN apt-get update -q && apt-get install -y -q curl && \
    mkdir /opt/tomcat && \
    curl https://downloads.apache.org/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz | \
    tar -xvz -C /opt/tomcat --strip-components=1 && \
    apt-get autoremove -y curl && rm -rf /var/lib/apt/lists/*


## installer java (apt-get)
## et nettoyer le dépôt apt après

## ajouter un utilisateur tomcat avec le dossier /opt/tomcat comme home et le groupe propriétairers /opt/tomcat/webapps

## télécharger l'application sample https://tomcat.apache.org/tomcat-10.1-doc/appdev/sample/sample.war dans le dossier home 

## spécifier le propriétaire et groupe à tomcat 
## changer l'utilisateur à tomcat

## persister le dossier home pour accéder ou sauvegarder les apps

## pour communiquer avec httpd avec le port par défaut de tomcat  ???

## exécuter de manière dynamique (avec substitution) le binaire en foreground catalina.sh vs startup.sh ???
## et ajouter la sous commande pour lancer en one shot run ou start ???

