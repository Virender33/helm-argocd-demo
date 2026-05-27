pipeline {
    agent any

    environment {
        ECR_REGISTRY = "525530758671.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPO     = "myapp"
        GITHUB_REPO  = "https://github.com/Virender33/helm-argocd-demo.git"
        GIT_USER     = "Virender33"
        VALUES_FILE  = "apps/myapp-chart/values.yaml"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Code checked out from GitHub'
                sh 'ls -la'
            }
        }

        stage('Test') {
            steps {
                sh 'sudo apt-get install -y python3-pip python3-pytest -q'
                sh 'python3 -m pytest myapp/test_app.py -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${ECR_REPO}:${BUILD_NUMBER} ./myapp'
                sh 'docker images | grep myapp'
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ap-south-1 | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    docker tag ${ECR_REPO}:${BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPO}:${BUILD_NUMBER}
                    docker push ${ECR_REGISTRY}/${ECR_REPO}:${BUILD_NUMBER}
                '''
                echo 'Image pushed to ECR!'
            }
        }

        stage('Update Helm Chart') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-pat',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_PASSWORD'
                )]) {
                    sh '''
                        # Configure git identity
                        git config --global user.email "jenkins@ci.com"
                        git config --global user.name "Jenkins"

                        # Clone the repo using PAT for auth
                        rm -rf /tmp/helm-repo
                        git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Virender33/helm-argocd-demo.git /tmp/helm-repo

                        # Update the image tag in values.yaml
                        sed -i "s/  tag: .*/  tag: \\"${BUILD_NUMBER}\\"/" /tmp/helm-repo/${VALUES_FILE}

                        # Verify the change
                        grep "tag:" /tmp/helm-repo/${VALUES_FILE}

                        # Commit and push
                        cd /tmp/helm-repo
                        git add ${VALUES_FILE}
                        git commit -m "Jenkins build #${BUILD_NUMBER} - update image tag"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Virender33/helm-argocd-demo.git main
                    '''
                }
            }
        }

    }

    post {
        always {
            sh 'docker rmi ${ECR_REPO}:${BUILD_NUMBER} || true'
            sh 'docker rmi ${ECR_REGISTRY}/${ECR_REPO}:${BUILD_NUMBER} || true'
        }
        success { echo 'SUCCESS! Image in ECR + Helm chart updated!' }
        failure { echo 'FAILED! Check logs above.' }
    }
}
