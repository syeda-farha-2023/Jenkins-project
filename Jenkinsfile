pipeline {
    agent any
    environment {
        // Deployment configuration
        DEPLOY_TARGET = 'staging'
        FEATURE_X_ENABLED = 'true'
        TEST_ENVIRONMENT = 'integration'
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository
                git branch: 'main', url: 'https://github.com/syeda-farha-2023/Jenkins-project.git'
            }
        }
        stage('Activate Service Account') {
            steps {
                withCredentials([file(credentialsId: 'channelpay-cloud-function-admin-sa', variable: 'SERVICE_ACCOUNT_KEY_PATH')]) {
                    sh 'gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_KEY_PATH}"'
                }
            }
        }
        stage('Deploy Functions') {
            steps {
                script {
                    // List all subdirectories (ignoring the current directory)
                    def directories = sh(script: 'find . -mindepth 1 -maxdepth 1 -type d', returnStdout: true).trim().split('\n')
                    for (dir in directories) {
                        dir(dir) {
                            // Check if deploy.sh exists and execute it
                            if (fileExists('deploy.sh')) {
                                sh './deploy.sh'
                            } else {
                                // Use a generic deployment command if no deploy.sh exists
                                echo "No deploy.sh found in ${dir}, using default gcloud deploy command"
                                sh "gcloud functions deploy --runtime python39 --trigger-http --allow-unauthenticated"
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            mail to: 'sagar.vaghela@goapptiv.com',
                subject: "Pipeline Successful: ${env.JOB_NAME}",
                body: "Your Jenkins pipeline ${env.JOB_NAME} has completed successfully.\nBuild Number: ${env.BUILD_NUMBER}\nDuration: ${currentBuild.durationString}\nStatus: SUCCESS"
        }
        failure {
            mail to: 'sagar.vaghela@goapptiv.com',
                subject: "Pipeline Failed: ${env.JOB_NAME}",
                body: "Your Jenkins pipeline ${env.JOB_NAME} has failed. Please check the console output for more details.\nBuild Number: ${env.BUILD_NUMBER}\nDuration: ${currentBuild.durationString}\nStatus: FAILURE"
        }
        always {
            // Adjust cleanup commands as needed
            script {
                sh 'rm -f .env'
                sh 'rm -rf temp/*'
            }
        }
    }
}  
