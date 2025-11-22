@Library('cloudLib') _

pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
    GITHUB_CREDENTIALS = 'GitHub'
    IMAGE_NAME = "lenaadel/ivolve-app"
  }

  parameters {
    string(name: 'IMAGE_TAG', defaultValue: "v${BUILD_NUMBER}", description: 'Docker image tag')
    booleanParam(name: 'SCAN_IMAGE', defaultValue: false, description: 'Enable Trivy scan')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Image') {
      steps {
        script {
          def fullImage = "${env.IMAGE_NAME}:${params.IMAGE_TAG}"
          cloudLib.buildDockerImage(fullImage)
        }
      }
    }

    stage('Scan Image (Trivy)') {
      when { expression { return params.SCAN_IMAGE } }
      steps {
        sh "trivy image ${env.IMAGE_NAME}:${params.IMAGE_TAG} || true"
      }
    }

    stage('Docker Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
          sh "docker push ${env.IMAGE_NAME}:${params.IMAGE_TAG}"
        }
      }
    }

    stage('Cleanup Local Image') {
      steps {
        sh "docker rmi ${env.IMAGE_NAME}:${params.IMAGE_TAG} || true"
      }
    }

    stage('Update Manifests') {
      steps {
        script {
          sh """
            sed -i 's#image:.*#image: ${env.IMAGE_NAME}:${params.IMAGE_TAG}#' kubernetes/deployment.yaml
            git add kubernetes/deployment.yaml
            git commit -m "Update deployment image" || true
          """
        }
      }
    }

    stage('Push Manifests to GitHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.GITHUB_CREDENTIALS, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh """
            git remote set-url origin https://$GIT_USER:$GIT_PASS@github.com/your-github-username/CloudDevOpsProject.git
            git push origin main || true
          """
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
