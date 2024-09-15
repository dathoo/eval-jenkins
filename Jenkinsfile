pipeline {
    agent any
    environment {
        KUBE_NAMESPACE = ''
        HELM_CHART_NAME = "movie-cast-app"
    }
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Environment to deploy to')
    }
    stages {
        // stage('Determine Namespace') {
        //     steps {
        //         script {
        //             switch (env.BRANCH_NAME) {
        //                 case 'main':
        //                     KUBE_NAMESPACE = 'prod'
        //                     break
        //                 case 'staging':
        //                     KUBE_NAMESPACE = 'staging'
        //                     break
        //                 case 'qa':
        //                     KUBE_NAMESPACE = 'qa'
        //                     break
        //                 default:
        //                     KUBE_NAMESPACE = 'dev'
        //             }
        //         }
        //     }
        // }
        // stage('Checkout') {
        //     steps {
        //         git branch: '${BRANCH_NAME}', url: 'https://github.com/dathoo/eval-jenkins.git'
        //     }
        // }
        // stage('Helm Deploy') {
        //     steps {
        //         // script {
        //         //     sh """
        //         //     helm upgrade --install ${HELM_CHART_NAME} ./helm-chart \\
        //         //     --namespace ${KUBE_NAMESPACE} \\
        //         //     --set namespace=${KUBE_NAMESPACE}
        //         //     """
        //         // }
        //         script {
        //             def environment = "${params.ENVIRONMENT}"
        //             def valuesFile = "helm-chart/environments/${environment}-values.yaml"

        //             echo "Deploying to environment: ${environment}"

        //             sh """
        //                 helm upgrade --install movie-cast-app ./helm-chart/ \
        //                 --namespace ${environment} \
        //                 --values ${valuesFile}
        //             """
        //         }
        //     }
        // }


        stage('Create Namespaces') {
            steps {
                // Todo: adapt path to file 
                sh 'kubectl apply -f namespaces.yaml'
            }
        }
        stage('Build') {
            steps {
                // Build steps
            }
        }
        stage('Deploy to Dev') {
            when {
                branch 'dev'
            }
            steps {
                // Deploy to Dev
            }
        }
        stage('Deploy to QA') {
            when {
                branch 'qa'
            }
            steps {
                // Deploy to QA
            }
        }
        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                // Deploy to Staging
            }
        }
        stage('Manual Approval for Production') {
            when {
                branch 'main'
            }
            input {
                message "Déployer en Production?"
            }
            steps {
                // Deploy to Production
            }
        }
    }
}