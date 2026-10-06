pipeline {

    agent any

    triggers {
        pollSCM('0 H/4 * * *')
    }

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

        stage('Checkout') {
            steps {
                echo 'Checkout repository code...'
                checkout scm
            }
        }

        stage('Test') {
            steps {
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
                        credentialsId: 'docker-credentials',
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

        stage('Deploy Via SSH') {
            environment {
                // Change these three values to match your ngrok status and WSL account
                SSH_HOST = '0.tcp.in.ngrok.io' 
                SSH_PORT = '22586' 
                SSH_USER = 'janet_john' 
            }
            steps {
                sshagent(['ssh-server-credentials']) {
                    sh '''
                        set -e
                        echo "Connecting to remote server..."

                        ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_USER}@${SSH_HOST}" << 'EOF'
                            set -e
                            echo "Connected to the Remote server"

                            echo "Checking Containerd"
                            sudo containerd --version

                            echo "Checking nerdctl"
                            sudo nerdctl --version

                            echo "Pulling image from Docker Hub"
                            sudo nerdctl --address /run/containerd/containerd.sock pull docker.io/janetjohn15/mypythonapp:latest

                            echo "Removing previous container if it exists"
                            sudo nerdctl --address /run/containerd/containerd.sock rm -f mypythonapp || true

                            echo "Running container"
                            sudo nerdctl --address /run/containerd/containerd.sock run -d \
                                --name mypythonapp \
                                docker.io/janetjohn15/mypythonapp:latest

                            echo "Checking container status"
                            sudo nerdctl --address /run/containerd/containerd.sock ps -a

                            echo "Showing test results from container"
                            sudo nerdctl --address /run/containerd/containerd.sock logs mypythonapp
EOF
                    '''
                }
            }
        }
    }
}
