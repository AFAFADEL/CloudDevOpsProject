def buildDockerImage(image) {
    sh "docker build -t ${image} ."
}

def pushDockerImage(image) {
    sh "docker push ${image}"
}

def deleteLocalImage(image) {
    sh "docker rmi ${image} || true"
}
