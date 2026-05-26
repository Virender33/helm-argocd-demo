pipeline {
    agent any
    environment {
        ECR_REGISTRY = "525530758671.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPO     = "myapp"
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
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
                sh 'docker images | grep myapp'
            }
        }
        stage('Push to ECR') {
            steps {
                sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 525530758671.dkr.ecr.ap-south-1.amazonaws.com'
                sh 'docker tag myapp:${BUILD_NUMBER} 525530758671.dkr.ecr.ap-south-1.amazonaws.com/myapp:${BUILD_NUMBER}'
                sh 'docker push 525530758671.dkr.ecr.ap-south-1.amazonaws.com/myapp:${BUILD_NUMBER}'
                echo 'Image pushed to ECR!'
            }
        }
    }
    post {
        success { echo 'SUCCESS! Image is in ECR!' }
        failure { echo 'FAILED!' }
    }
}
