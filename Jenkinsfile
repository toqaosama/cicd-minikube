pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'toqaosama'          // <-- change me
        IMAGE_NAME     = "${DOCKERHUB_USER}/python-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        FULL_IMAGE     = "${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $FULL_IMAGE -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DH_USER',
                                                  passwordVariable: 'DH_PASS')]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push $FULL_IMAGE
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                // Secret File credential containing the Minikube kubeconfig
                withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        sed "s|IMAGE_PLACEHOLDER|$FULL_IMAGE|g" K8s/deployment.yaml > K8s/deployment.rendered.yaml
                        kubectl apply -f K8s/deployment.rendered.yaml
                        kubectl apply -f K8s/service.yaml
                        kubectl rollout status deployment/python-app --timeout=120s
                    '''
                }
            }
        }

        stage('Verify') {
            steps {
                withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'kubectl get pods && kubectl get services'
                }
            }
        }
    }

    post {
        always  { sh 'docker logout || true' }
        success { echo "Deployed ${env.FULL_IMAGE} to Minikube" }
        failure { echo 'Pipeline failed - check the stage logs above.' }
    }
}
