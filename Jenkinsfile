pipeline {
  agent any

  options {
    timestamps()
  }

  environment {
    REGISTRY = "docker.io"
    IMAGE_NAMESPACE = "aliagpak"
    MOVIE_IMAGE = "${REGISTRY}/${IMAGE_NAMESPACE}/movie-service"
    CAST_IMAGE = "${REGISTRY}/${IMAGE_NAMESPACE}/cast-service"
    IMAGE_TAG = "${env.BUILD_NUMBER}"

    HELM_RELEASE = "fastapiapp"
    HELM_CHART = "./charts"
    STAGING_NAMESPACE = "staging"
    PROD_NAMESPACE = "production"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Images') {
      steps {
        sh 'docker build -t ${MOVIE_IMAGE}:${IMAGE_TAG} movie-service'
        sh 'docker build -t ${CAST_IMAGE}:${IMAGE_TAG} cast-service'
      }
    }

    stage('Push Images') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-registry', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${REGISTRY}'
          sh 'echo "Pushing ${MOVIE_IMAGE}:${IMAGE_TAG}"'
          sh 'docker push ${MOVIE_IMAGE}:${IMAGE_TAG}'
          sh 'echo "Pushing ${CAST_IMAGE}:${IMAGE_TAG}"'
          sh 'docker push ${CAST_IMAGE}:${IMAGE_TAG}'
          sh 'docker logout ${REGISTRY}'
        }
      }
    }

    stage('Deploy Dev (Docker Compose)') {
      steps {
        sh 'docker-compose up -d --build'
      }
    }

    stage('Deploy Staging (Helm)') {
      when {
        not {
          expression {
            return (env.BRANCH_NAME == 'master') || (env.GIT_BRANCH == 'origin/master')
          }
        }
      }
      steps {
        sh 'echo "BRANCH_NAME=${BRANCH_NAME:-}"; echo "GIT_BRANCH=${GIT_BRANCH:-}"; echo "GIT_LOCAL_BRANCH=${GIT_LOCAL_BRANCH:-}"'
        sh 'env | sort | grep -E "^(BRANCH|GIT)_" || true'
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh 'set -e; echo "KUBECONFIG=$KUBECONFIG"; ls -l "$KUBECONFIG"'
          sh 'kubectl config view --minify'
          sh 'kubectl get ns'
          sh 'helm list -A'
          sh 'helm upgrade --install ${HELM_RELEASE} ${HELM_CHART} -n ${STAGING_NAMESPACE} --create-namespace \
            --set image.repository=${MOVIE_IMAGE} \
            --set image.tag=${IMAGE_TAG}'
        }
      }
    }


    stage('Deploy Prod (Helm)') {
      when {
        expression {
          return (env.BRANCH_NAME == 'master') || (env.GIT_BRANCH == 'origin/master')
        }
      }
      steps {
        input message: 'Production deploy onaylıyor musun?', ok: 'Deploy'
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
 	  sh 'set -e; echo "KUBECONFIG=$KUBECONFIG"; ls -l "$KUBECONFIG"'
          sh 'kubectl get ns'
          sh 'helm list -A'
          sh 'helm upgrade --install ${HELM_RELEASE} ${HELM_CHART} -n ${PROD_NAMESPACE} --create-namespace \
            --set image.repository=${MOVIE_IMAGE} \
            --set image.tag=${IMAGE_TAG}'
        }
      }
    }
  }
}

