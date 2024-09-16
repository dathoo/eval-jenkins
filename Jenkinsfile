pipeline {

    agent any

    environment {
        GITHUB_REPO = 'https://github.com/dathoo/eval-jenkins.git'
        HELM_CHART_PATH = './helm-chart'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "${GITHUB_REPO}", branch: "${BRANCH_NAME}"
            }
        }

        stage('Helm Deployment') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                script {
                    if (BRANCH_NAME == 'dev' || BRANCH_NAME == 'qa' || BRANCH_NAME == 'staging') {
                        sh "helm upgrade --install movie-api-${BRANCH_NAME} ${HELM_CHART_PATH} --namespace ${BRANCH_NAME} --create-namespace -f ${HELM_CHART_PATH}/environments/${BRANCH_NAME}-values.yaml"
                    }
                }
            }
        }

        stage('Manual Prod Deployment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    input message: 'Deploy to Production?', ok: 'Deploy'
                    sh "movie-api-prod ${HELM_CHART_PATH} --namespace prod --create-namespace -f ${HELM_CHART_PATH}/environments/prod-values.yaml"
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
