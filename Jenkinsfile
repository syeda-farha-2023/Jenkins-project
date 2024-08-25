pipeline {
    agent any

    stages {
        stage("Checkout") {
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
                    // Get the base branch (target branch of the PR)
                    def targetBranch = env.CHANGE_TARGET ?: 'main'
                    
                    // Determine the branch the PR is based on
                    def currentBranch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()

                    // Compare the current branch with the target branch of the PR
                    def changedFiles = sh(script: "git diff --name-only origin/${targetBranch}...${currentBranch}", returnStdout: true).trim().split('\n')

                    def updatedFunctions = []
                    def changedDirs = changedFiles.collect { it.split('/')[0] }.unique()

                    // Set environment variable for changed directories
                    env.CHANGED_DIRS = changedDirs.join(',')
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
