pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'hranden/nginx-app'
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
                            sed -i 's|YOUR_DOCKERHUB_USERNAME/nginx-app:latest|${DOCKER_IMAGE}:latest|g' k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            
                            # Wait for rollout to complete
                            kubectl rollout status deployment/nginx-app -n nginx
                            
                            # Show deployment status
                            echo "Deployment Status:"
                            kubectl get deployment nginx-app -n nginx
                            
                            # Show pods
                            echo "Pods:"
                            kubectl get pods -l app=nginx-app -n nginx
                            
                            # Show service info
                            echo "Service:"
                            kubectl get svc nginx-app-service -n nginx
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
            echo '  kubectl get pods -l app=nginx-app -n nginx'
            echo '  kubectl get svc nginx-app-service -n nginx'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
        }
    }
}
