pipeline {
    agent any
    
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('service-account') // Replace 'service-account' with your Jenkins credentials ID
        PROJECT_ID = 'devops-testing-419206' // Replace with your actual project ID
        REGION = 'asia-south1' // Replace with your actual region
    }

    triggers {
        githubPullRequest {
            triggerPhrase('deploy') // Phrase used in PR comments to trigger deployments
            onlyTriggerPhrase(true) // Only trigger on the specified phrase
        }
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository
                git branch: 'main', url: 'https://github.com/your-username/your-repository.git'
            }
        }
        stage('Detect Changes') {
            steps {
                script {
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

                    echo "Updated cloud functions: ${updatedFunctions}"
                }
            }
        }

        stage('Deploy Updated Functions') {
            steps {
                script {
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

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}



