pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'hranden/nginx'
        KUBE_CONFIG = credentials('kubeconfig')
        export PATH="/usr/local/bin:$PATH"
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
                        /usr/local/bin/docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        /usr/local/bin/docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:stable
                    """
                }
            }
        }
        
// stage('Run Tests') {
//     steps {
//         script {
//             sh """
//                 /usr/local/bin/docker run --rm ${DOCKER_IMAGE}:${BUILD_NUMBER} \
//                 sh -c 'pip install pytest && pytest test_app.py -v'
//             """
//         }
//     }
// }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                        echo \$DOCKER_HUB_CREDENTIALS_PSW | /usr/local/bin/docker login -u \$DOCKER_HUB_CREDENTIALS_USR --password-stdin
                        /usr/local/bin/docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        /usr/local/bin/docker push ${DOCKER_IMAGE}:stable
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
                        sed -i 's|YOUR_DOCKERHUB_USERNAME/nginx:stable|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' k8s/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for rollout
                        kubectl rollout status deployment/nginx-deployment -n nginx
                        
                        # Get service info
                        kubectl get svc nginx-service -n nginx
                        kubectl get deployment nginx-deployment -n nginx
                            
                        # Show pods
                        echo "Pods:"
                        kubectl get pods -l app=nginx -n nginx
                            
                        # Show service info
                        echo "Service:"
                        kubectl get svc nginx-service -n nginx
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
