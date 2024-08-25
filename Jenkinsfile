pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Activate Service Account') {
            steps {
                withCredentials([file(credentialsId: 'channelpay-cloud-function-admin-sa', variable: 'SERVICE_ACCOUNT_KEY_PATH')]) {
                    script {
                        sh 'gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_KEY_PATH}"'
                    }
                }
            }
        }

        stage('Detect Changes') {
            steps {
                script {
                    // Get the target branch from the PR or default to 'master'
                    def targetBranch = env.CHANGE_TARGET ?: 'master'
                    
                    // Get the PR source branch
                    def sourceBranch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()

                    // Fetch only the target branch and the source branch
                    sh "git fetch origin ${targetBranch}:${targetBranch}"
                    sh "git fetch origin ${sourceBranch}:${sourceBranch}"

                    // Compare changes between the PR source branch and the target branch
                    def changedFiles = sh(script: "git diff --name-only ${targetBranch}...${sourceBranch}", returnStdout: true).trim().split('\n')

                    // Extract unique top-level directories
                    def updatedFunctions = changedFiles.collect { it.split('/')[0] }.unique()

                    // Set environment variable with changed directories
                    env.CHANGED_DIRS = updatedFunctions.join(',')
                }
            }
        }

        stage('Deploy Functions') {
            steps {
                script {
                    def directories = env.CHANGED_DIRS.split(',')

                    directories.each { dirPath ->
                        def cleanDirPath = dirPath.replaceFirst(/^.\//, '')

                        if (fileExists("${cleanDirPath}/deploy.sh")) {
                            dir("${cleanDirPath}") {
                                sh 'chmod +x deploy.sh && ./deploy.sh'
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
            }
        }
    }
}
