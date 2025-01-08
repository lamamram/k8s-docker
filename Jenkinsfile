pipeline {
    // a priori on utilise l'agent i.e, le shell du conteneur jenkins
    agent any

    stages {
        stage('Build Docker') {
            agent {
                // je veux lancer des conteneurs à partir du conteneur jenkins
                docker {
                    // quel conteneur
                    image 'alpine:latest'
                    // options du docker run
                    //args ''
                }
            }
            steps {
                sh '''
                pwd
                echo "test alpine!"
                id
                '''
            }
        }
    }
}