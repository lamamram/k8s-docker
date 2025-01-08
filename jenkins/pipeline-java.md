# build du pipeline maven

## version agent "any" => exécution sur jenkins en local

* guide : [doc](https://www.jenkins.io/blog/2017/02/07/declarative-maven-project/)

1. préparer les outils prérequis
  - maven
  - un jdk 17

2. ajouter maven et le jdk dans 
  - Administrer Jenkins
  - tools
  - maven > nom  + version
  - jdk > nom

3. le plugin maven + pipeline

4. ajouter la section tools dans le Jenkinsfile pour selectionner les éléments prréexistant

5. scrutation du dépôt git
  - version naïve: 
     + projet dev 
     + configurer 
     + section Triggers
     + scrutation SCM > planning H/4 * * * *
  - version performante
     + hook post-receive 
     + enlever le planning

### job units

* stage TEST
  - steps: sh 'mvn test' > puisque les plugins de rapports test / couverture dans le pom.xml
  - post: remontée des rapports
    + junit pour surefire
    + recordCoverage pour jacoco
  - amélioration avec le plugin failsafe + sub-goal maven "maven" dans le pom
  - permet d'utiliser le goal `mvn verify` avec units et integration comptabilisés ensemble dans les rapports

### job qualité

* automatiser le formatage du code selon les conventions d'éctirures spécifiées dans le manuel d'assurance qualité
  - ajouter le plugin **maven-formatter** dans le pom.xml
  - // le fichier de config `src/main/resources/formatter.xml`
  - permet d'utiliser le goal `mvn formatter:format`
  - automatiser avant les commits: `.git/hooks/pre-commit`

* stage QUALITY
  - effectuer une analyse statique de code (SAST) Static Application Security Testing GRATUIT
  - vs DAST Dynamic => analyse *in vivo* / analyse de conformité aux standards PAYANT
  - vs pentesting => tests d'intrusion => simuler une attaque (juridique) DIY (kali linux)

* outils sonarQube de SonarSource
  - outils client (sonarscanner) / serveur (sonarQube)
  - côté client : goal `mvn sonar` ajouté par le plugin **sonar-maven-plugin** dans le pom
  - côté serveur : conteneur sonarQube (cf infra)

#### setup

1. création du conteneur sonarqube

```bash
docker run \
    --name sonar \
    -d --restart unless-stopped \
    -p 9000:9000 \
    --net jenkins-net \
    --memory 6g \
    sonarqube:lts
```

   * REM: ajout du CGROUP memory pour limiter l'utilisation de la RAM au conteneur sonarqube, il faut ajouter le -xmx de la jvm dans le conteneur sonarqube

2. création et configuration d'un projet sonar avec un profile qualité et une gate

   * `http://jenkins.myusine.fr:9000` > admin / admin
   * change pour admin / roottoor
   * config manuelle
   * token: sqp_134a4f503d3b5c19a603a07d1aa61a9d45cac250
   * snippet a priori de la connexion

   ```bash
   mvn clean verify sonar:sonar \
      -Dsonar.projectKey=dev \
      -Dsonar.host.url=http://jenkins.myusine.fr:9000 \
      -Dsonar.login=sqp_134a4f503d3b5c19a603a07d1aa61a9d45cac250
   ```

   * création du profile qualité
      - java (profile par défaut)
      - copie (activation/désactivation de règles) vs extension (activation de règles)
      - attache le profile au projet
  
   *  création d'une "gate" > seuil de validation d'acceptabilité de l'analyse
      - gate par défaut pour le nouveau code
      - customisation des critères
      - certains critères ne peut être calculés directement par SonarQube par ex. coverage
   
   * configuration client (voir jenkinsfile)
      - steps avec le script mvn sonar
      - masquer les secrets avec le plugin **credentials binding** (auto)
        + création d'un crendential de type secret text
        + directive **withCredential**
      - compiler avant de exécuter le goal sonar
      - ajouter la config **java.binaries** pour connaitre l'emplacement des fichiers compilés
      - ajouter l'évaluation de la gate
      - transferer le rapport de couverture depuis le stage précedent avec
        + les directives **stash / unstash** 
    
       
### job test interfaces

* on va utiliser un conteneur dynamique avec 
  - une image maven 
  - dans le réseau docker de jenkins
  - en partageant le dépôt de dépendance m2
* on va ajouter un conteneur selenium `selenium/standalone-firefox:133.0-geckodriver-0.35` dans le réseau

```bash
docker run \
       --name selenium \
       -d --restart unless-stopped \
       --net jenkins-net \
       selenium/standalone-firefox:133.0-geckodriver-0.35
```

* avant de lancer les tests
  - décompresser le driver dans le conteneur
  - l'installer en exécution dans le PATH
  - côté client selenium => utiiser le nom du conteneur
  - utiliser l'option **headless**

* attention à la glue / le resourceclasspath dans `src/test/java/bdd/CucumberTest.java`

* rapports de tests
  - spécifier les formats désirés dans `src/test/resources/junit-platform.properties`
  - ajouter le plugin jenkins **Cucumber reports**