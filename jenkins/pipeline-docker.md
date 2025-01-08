# build du pipeline docker

## agent "any" => exécution sur jenkins en local

## job build d'image avec l'agent docker

* pour utiliser l'agent docker: 
  - le conteneur jenkins doit connaître docker (cli + daemon)
  - le conteneur doit utiliser le même UID:GID du docker de la VM
  ```yaml
     # compose.yml : version NAÏVE PEU SECURISEE
     ...
     user: jenkins:996
     volumes:
       ...
       - /usr/bin/docker:/usr/bin/docker
       - /var/run/docker.sock:/var/run/docker.sock
  ```

  * configuration d'un conteneur dynamique / éphémère

  ```groovy
    agent {
    docker {
        //image '<img>:<tag>'
        image 'docker:27.3.1'
        // options du docker run
        args ' -u root -v /var/run/docker.sock:/var/run/docker.sock --add-host formation.lan:172.17.0.1'
        // -u root: il n'y a pas de UID 1000 dans ce conteneur
        // -v ... : pour connecter le daemon docker de la VM (UNSAFE)
        // --add-host: pour connaître l'ip du host du registre
    }
  ```

  * procédure de test

  ```groovy
    steps {
        // build
        // lancement du conteneur détaché
        // attendre la fin du HealtCheck
        // filtrer le docker ps sur ce conteneur
        // regarder si c'est healthy
        // pb avec le "|"
        sh '''
        ...
        '''
    }
  ```

  * traitement en fin de procédure

  ```groovy
    // post s'excute après les steps
    post {
        // success: condition d'exécution
        success {
            // withCredentials: utilisation d'un Credential Jenkins (cf GUI ou jenkins-cli) 
            withCredentials([
                string(credentialsId: '<credential-id>', variable: 'ENV_VAR')
            ]) {
                sh '''
                  ... $ENV_VAR ...
                '''
            }
        }
    }
  ```


