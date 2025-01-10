pipeline {
    // a priori on utilise l'agent i.e, le shell du conteneur jenkins
    agent any

    stages {
        stage('Build Docker') {
            // deactivate job !!
            when {
                expression { false }
            }
            agent {
                // je veux lancer des conteneurs à partir du conteneur jenkins
                docker {
                    // quel conteneur
                    //image 'alpine:latest'
                    image 'docker:27.3.1'
                    // options du docker run
                    args ' -u root -v /var/run/docker.sock:/var/run/docker.sock --add-host formation.lan:172.17.0.1'
                    // avec un serveur dind
                    // args ' -u root --net jenkins-net -e DOCKER_HOST=tcp://dind:2376 --add-host formation.lan:172.20.0.1'
                }
            }
            steps {
                // test
                sh '''
                cd stack-java/httpd
                docker build -t formation.lan:443/stack-java-httpd:1.0 .
                docker run --name=test -d formation.lan:443/stack-java-httpd:1.0
                sleep 6
                echo "$(docker ps --filter name=test)" > test
                grep "(healthy)" test
                '''
            }
            //nettoyage
            post {
                // condition d'exécution du traitements POST step
                // always never unsuccess
                success {
                    // upload de l'image dans le registre
                    // masquage du mdp du registre avec un credential
                    withCredentials([
                        string(credentialsId: 'registry-token', variable: 'REGISTRY_TOKEN')
                    ]) {
                        sh '''
                        docker login -u testuser -p $REGISTRY_TOKEN formation.lan:443/stack-java-httpd:1.0
                        docker push formation.lan:443/stack-java-httpd:1.0
                        '''
                    }
                    
                    sh '''
                    docker rm -f test
                    '''
                }
            }
        }
        stage('Deploy app') {
            // node {
            //     ajouter CLUSTER_ADDR dans un fichier groovy
            //     exécuter le groovy pour charger la variable
            //     load "$JENKINS_HOME/.envvars/custom_envs.groovy"
            //     echo "${env.CLUSTER_ADDR}"
            // }
            agent {
                docker {
                    image 'bitnami/kubectl:1.30'
                    // args ' -u root -v /var/jenkins_home/config:/.kube/config --add-host autoelb.lan:${env.CLUSTER_ADDR}'
                    args ' -u root -v /var/jenkins_home/config:/.kube/config --add-host autoelb.lan:192.168.1.32'
                }
            }
            steps {
                sh '''
                kubectl cluster-info
                '''
            }
        }
    }
}