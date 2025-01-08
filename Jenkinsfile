pipeline {
    // a priori on utilise l'agent i.e, le shell du conteneur jenkins
    agent any

    stages {
        stage('Build Docker') {
            agent {
                // je veux lancer des conteneurs à partir du conteneur jenkins
                docker {
                    // quel conteneur
                    //image 'alpine:latest'
                    image 'docker:27.3.1'
                    // options du docker run
                    args ' -u root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh '''
                cd stack-java/httpd
                docker build -t stack-java-httpd:1.0 .
                docker run --name=test -d stack-java-httpd:1.0
                sleep 6
                echo "$(docker ps --filter name=test)" > test
                grep "(healthy)" test
                '''
            }
            //nettoyage
            post {
                // condition d'exécution du traitements POST step
                success {
                    sh '''
                    docker rm -f test
                    '''
                }
            }
        }
    }
}