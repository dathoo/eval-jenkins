pipeline {

    agent any

    environment {
        GITHUB_REPO = 'https://github.com/dathoo/eval-jenkins.git'
        HELM_CHART_PATH = './helm-chart'
        DOCKER_ID = "damdam1977"
        DOCKER_IMAGE_CAST = "cast-service"
        DOCKER_IMAGE_MOVIE = "movie-service"
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }

    stages {

        stage('Docker Build & Push'){
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // we retrieve  docker password from secret text called docker_hub_pass saved on jenkins
            }
            steps {
                script {
                    sh '''
                    cd ./cast-service/
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG .
                    sleep 6
                    cd ../movie-service/
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG .
                    sleep 6
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                    docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Checkout branch') {
            steps {
                git url: "${GITHUB_REPO}", branch: "${BRANCH_NAME}"
            }
        }

        stage('Helm Deployment to dev or qa or staging') {
            when {
                not {
                    branch 'main'
                }
            }
            environment {
                KUBECONFIG = credentials('config')
            }
            steps {
                script {
                    if (BRANCH_NAME == 'dev' || BRANCH_NAME == 'qa' || BRANCH_NAME == 'staging') {
                        sh '''
                        mkdir -p .kube
                        echo "$KUBECONFIG" > .kube/config
                        mkdir -p ./tmp
                        cp ${HELM_CHART_PATH}/environments/${BRANCH_NAME}-values.yaml ./tmp/values.yaml
                        sed -i "s/tag.*/tag: ${DOCKER_TAG}/g" ./tmp/values.yml
                        helm upgrade --install movie-api-${BRANCH_NAME} ${HELM_CHART_PATH} --namespace ${BRANCH_NAME} --create-namespace -f ./tmp/values.yaml
                        '''
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
                    sh '''
                    mkdir -p .kube
                    echo "$KUBECONFIG" > .kube/config
                    mkdir -p ./tmp
                    cp ${HELM_CHART_PATH}/environments/prod-values.yaml ./tmp/values.yaml
                    sed -i "s/tag.*/tag: ${DOCKER_TAG}/g" ./tmp/values.yml
                    helm upgrade --install movie-api-prod ${HELM_CHART_PATH} --namespace prod --create-namespace -f ./tmp/values.yaml
                    '''
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
