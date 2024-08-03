pipeline {
    agent any

    environment {
        // Define environment variables if needed
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

        stage('Detect Changes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'channelpay-cloud-function-admin-sa', variable: 'SERVICE_ACCOUNT_KEY_PATH')]) {
                        // Get the list of modified files from the PR
                        def changedFiles = sh(script: 'git diff --name-only origin/main...HEAD', returnStdout: true).trim().split('\n')

                        // Initialize an empty list to store updated cloud functions
                        def updatedFunctions = []

                        // Detect which cloud functions have been modified
                        for (file in changedFiles) {
                            if (file.startsWith('cloud_function1/')) {
                                updatedFunctions.add('cloud_function1')
                            } else if (file.startsWith('cloud_function2/')) {
                                updatedFunctions.add('cloud_function2')
                            }
                        }

                        // Remove duplicates
                        updatedFunctions = updatedFunctions.unique()

                        // Store the result in an environment variable
                        env.UPDATED_FUNCTIONS = updatedFunctions.join(',')
                    }
                }
            }
        }

        stage('Deploy Updated Functions') {
            steps {
                script {
                    def updatedFunctions = env.UPDATED_FUNCTIONS.split(',')
                    
                    withCredentials([file(credentialsId: 'channelpay-cloud-function-admin-sa', variable: 'SERVICE_ACCOUNT_KEY_PATH')]) {
                        // Loop through updated functions and deploy each one
                        for (function in updatedFunctions) {
                            dir(function) {
                                sh './deploy.sh'
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
            script {
                sh 'rm -f .env'
                sh 'prune -f -a'
            }
        }
    }
}
