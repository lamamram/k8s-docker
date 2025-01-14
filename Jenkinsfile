pipeline {
    // a priori on utilise l'agent i.e, le shell du conteneur jenkins
    agent any

    stages {
        stage('Build Docker') {
            //deactivate job !!
            when {
                beforeAgent true
                expression { false }
            }
            agent {
                // je veux lancer des conteneurs à partir du conteneur jenkins
                docker {
                    // quel conteneur
                    //image 'alpine:latest'
                    image 'docker:27.3.1'
                    // options du docker run
                    args ' -u root -v /var/run/docker.sock:/var/run/docker.sock --add-host jenkins.lan:172.17.0.1'
                    // avec un serveur dind
                    // args ' -u root --net jenkins-net -e DOCKER_HOST=tcp://dind:2376 --add-host jenkins.lan:172.20.0.1'
                }
            }
            environment {
                IMG_TAG = "v1.2"
            }
            steps {
                // test
                sh '''
                cd stack-java/httpd
                docker build --build-arg TOMCAT_VERSION_FULL=9.0.98 -t jenkins.lan:443/stack-java-tomcat:$IMG_TAG .
                docker run --name=test -d jenkins.lan:443/stack-java-tomcat:$IMG_TAG
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
                        docker login -u testuser -p $REGISTRY_TOKEN jenkins.lan:443
                        docker push jenkins.lan:443/stack-java-tomcat:$IMG_TAG
                        '''
                    }
                    
                    sh '''
                    docker rm -f test
                    '''
                }
            }
        }
        stage('Deploy app') {
            when {
                beforeAgent true
                beforeInput true
                expression { true }
            }
            input {
                message "deploy this tag ?"
                submitter "admin"
            }
            // node {
            //     ajouter CLUSTER_ADDR dans un fichier groovy
            //     exécuter le groovy pour charger la variable
            //     load "$JENKINS_HOME/.envvars/custom_envs.groovy"
            //     echo "${env.CLUSTER_ADDR}"
            // }
            agent {
                docker {
                    image 'bitnami/kubectl:1.30'
                    // args ' -u root -v /var/jenkins_home/config:/.kube/config --add-host autoks.lan:${env.CLUSTER_ADDR}'
                    args ' -u root --add-host autoks.lan:192.168.1.32 --entrypoint=""'
                }
            }
            steps {
                // test: kubectl cluster-info
                sh '''
                cp /var/jenkins_home/config /.kube/config
                cd k8s 
                kubectl apply -f stack-java-ns.yml 
                kubectl apply -k .
                '''
            }
        }
    }
}