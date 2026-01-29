pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'hranden/alpine-app'
        KUBE_CONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/hranden/my-app.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    sh """
                        docker run --rm ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        sh -c 'pip install pytest && pytest test_app.py -v'
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                        echo \$DOCKER_HUB_CREDENTIALS_PSW | docker login -u \$DOCKER_HUB_CREDENTIALS_USR --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        mkdir -p ~/.kube
                        cat \$KUBE_CONFIG > ~/.kube/config
                        
                        # Update image in deployment
                        sed -i 's|YOUR_DOCKERHUB_USERNAME/alpine-app:latest|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' k8s/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for rollout
                        kubectl rollout status deployment/alpine-app
                        
                        # Get service info
                        kubectl get svc alpine-app-service
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
            cleanWs()
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
