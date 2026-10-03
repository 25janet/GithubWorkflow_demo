pipeline{
    agent{
        docker{
            image 'ubuntu-latest'
        }
    }

    environment{
        REGISTRY: docker.io
        IMAGE_NAME: janetjohn15/mypythonapp
    }
    stages{
        stage('CI Pipeline Initialization') {
            steps {
                // You can access your environment variables using "${env.VARIABLE_NAME}"
                echo "Starting pipeline for registry: ${env.REGISTRY}"
                echo "Target Image Name: ${env.IMAGE_NAME}"
            }
        }

        stage('test'){
            agent {
                    docker{
                        image 'python:3.14-alpine'
                        reuseNode true
                    }
            steps{
                echo 'Checkout the repository code...'
                checkout scm

                echo 'Install dependecies..'
                sh 'python -m pip install --upgrade pip'
                sh 'pip install -r requirements.txt'

                echo 'Run automates tests'
                sh 'pytest'
                
                }
            }
        }
        stage('Log in to docker'){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_TOKEN2'

                )])
                {
                    // Logs in to Docker Hub using the masked credentials
                    sh "echo '${DOCKERHUB_TOKEN2}' | docker login -u '${DOCKERHUB_USERNAME}' --password-stdin"
                }
            }
        }
        stage('Build-and-push'){
            steps{
                echo 'Build docker image'
                sh "docker build -t ${env.REGISTRY}/${env.IMAGE_NAME}:latest ."
                echo 'Push image to Registry'
                sh "docker push ${env.REGISTRY}/${env.IMAGE_NAME}:latest"
            }
        }
    }
}