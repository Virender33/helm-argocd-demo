pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                sh 'pwd'
            }
        }
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'echo Build number is ${BUILD_NUMBER}'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                sh 'echo All tests passed!'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'echo Deployed version ${BUILD_NUMBER}!'
            }
        }
    }
    post {
        success { echo 'Pipeline SUCCESS!' }
        failure { echo 'Pipeline FAILED!' }
    }
}
