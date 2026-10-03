pipeline {

    agent any

    environment {
        REGISTRY = 'docker.io'
        IMAGE_NAME = 'janetjohn15/mypythonapp'
    }

    stages {

        stage('CI Pipeline Initialization') {
            steps {
                echo "Starting pipeline for registry: ${env.REGISTRY}"
                echo "Target Image Name: ${env.IMAGE_NAME}"
            }
        }

       stage('Test') {
    steps {
        echo 'Checkout the repository code...'
        checkout scm

        echo 'Create Python virtual environment...'
        sh 'python3 -m venv .venv'

        echo 'Install dependencies...'
        sh '.venv/bin/python -m pip install --upgrade pip'
        sh '.venv/bin/pip install -r requirements.txt'

        echo 'Run automated tests...'
        sh '.venv/bin/pytest'
    }
}

        stage('Log in to Docker') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN2'
                    )
                ]) {
                    sh '''
                        echo "$DOCKERHUB_TOKEN2" | docker login \
                        -u "$DOCKERHUB_USERNAME" \
                        --password-stdin
                    '''
                }
            }
        }

        stage('Build-and-Push') {
            steps {
                echo 'Build Docker image...'

                sh "docker build -t ${env.REGISTRY}/${env.IMAGE_NAME}:latest ."

                echo 'Push image to Docker Hub...'

                sh "docker push ${env.REGISTRY}/${env.IMAGE_NAME}:latest"
            }
        }
    }
}