pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'nginx:latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/hranden/my-app.git'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Use withCredentials to properly handle the kubeconfig file
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            mkdir -p ~/.kube
                            cp "\$KUBECONFIG_FILE" ~/.kube/config
                            chmod 600 ~/.kube/config
                            
                            # Update image in deployment to use latest or specific tag
                            #sed -i 's|YOUR_DOCKERHUB_USERNAME/nginx-app:latest|${DOCKER_IMAGE}:latest|g' k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            
                            # Wait for rollout to complete
                            kubectl rollout status deployment/nginx-app
                            
                            # Show deployment status
                            echo "Deployment Status:"
                            kubectl get deployment nginx-app
                            
                            # Show pods
                            echo "Pods:"
                            kubectl get pods -l app=nginx-app
                            
                            # Show service info
                            echo "Service:"
                            kubectl get svc nginx-app-service
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
            echo 'To check your deployment:'
            echo '  kubectl get pods -l app=nginx-app'
            echo '  kubectl get svc nginx-app-service'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
        }
    }
}
