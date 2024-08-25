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
                    def targetBranch = env.CHANGE_TARGET ?: 'master'
                    def currentBranch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()

                    def branchToCompare = env.CHANGE_TARGET ? "origin/${targetBranch}" : "origin/${currentBranch}"

                    def changedFiles = sh(script: "git diff --name-only ${branchToCompare}...HEAD", returnStdout: true).trim().split('\n')

                    def updatedFunctions = []
                    def changedDirs = changedFiles.collect { it.split('/')[0] }.unique()

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
