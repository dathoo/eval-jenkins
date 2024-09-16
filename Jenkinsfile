def dockerBuildAndPush(imageTag) {
    sh """
        cd ./cast-service/
        docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:${imageTag} .
        sleep 6
        cd ../movie-service/
        docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:${imageTag} .
        sleep 6
        docker login -u $DOCKER_ID -p $DOCKER_PASS
        docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:${imageTag}
        docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:${imageTag}
    """
}

def deployToKubernetes(branchName) {
    sh """
        mkdir -p .kube
        echo "$KUBECONFIG" > .kube/config
        mkdir -p ./tmp
        cp ${HELM_CHART_PATH}/environments/${branchName}-values.yaml ./tmp/values.yaml
        sed -i "s/tag.*/tag: ${DOCKER_TAG}/g" ./tmp/values.yaml
        helm upgrade --install movie-api-${branchName} ${HELM_CHART_PATH} --namespace ${branchName} --create-namespace -f ./tmp/values.yaml
    """
}

pipeline {

    agent any

    environment {
        GITHUB_REPO = 'https://github.com/dathoo/eval-jenkins.git'
        HELM_CHART_PATH = './helm-chart'
        DOCKER_ID = "damdam1977"
        DOCKER_PASS = credentials("DOCKER_HUB_PASS") // we retrieve  docker password from secret text called docker_hub_pass saved on jenkins
        DOCKER_IMAGE_CAST = "cast-service"
        DOCKER_IMAGE_MOVIE = "movie-service"
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }

    stages {

        stage('Checkout branch') {
            steps {
                git url: "${GITHUB_REPO}", branch: "${BRANCH_NAME}"
            }
        }

        stage('Docker Build & Push dev images') {
            when {
                not { branch 'main' }
            }
            environment {
                DOCKER_TAG_DEV = "v.${BUILD_ID}.0-dev"  // Image avec des outils de dev/test
            }
            steps {
                script {
                    dockerBuildAndPush("${DOCKER_TAG_DEV}")
                }
            }
        }

        stage('Docker Build & Push prod images') {
            when {
                branch 'main'
            }
            environment {
                DOCKER_TAG_PROD = "v.${BUILD_ID}.0-prod"
            }
            steps {
                script {
                    dockerBuildAndPush("${DOCKER_TAG_PROD}")
                }
            }
        }

        stage('Helm Deployment to dev, qa, or staging') {
            when {
                not { branch 'main' }
            }
            environment {
                KUBECONFIG = credentials('config')
            }
            steps {
                script {
                    if (BRANCH_NAME in ['dev', 'qa', 'staging']) {
                        deployToKubernetes(BRANCH_NAME)
                    }
                }
            }
        }

        stage('Manual Prod Deployment') {
            when {
                branch 'main'
            }
            environment {
                KUBECONFIG = credentials('config')
            }
            steps {
                script {
                    input message: 'Deploy to Production?', ok: 'Deploy'
                    deployToKubernetes('prod')
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
        always {
            script {
                sh 'rm -rf ./tmp'
            }
        }
    }
}
