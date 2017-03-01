def version='1.0'

def mavenBuild(String ... args) {
  def mvnHome = tool 'M3'
  def gitCommit = getCommitId()
  sh "${mvnHome}/bin/mvn -B -Dtag=${gitCommit} " + args.join (' ')
  sh "echo Build ID = ${gitCommit}"
}

def mavenVerify () {
  def mvnHome = tool 'M3'
  sh "${mvnHome}/bin/mvn verify"
  step([$class: 'JUnitResultArchiver', testResults: '**/target/failsafe-reports/TEST-*.xml'])
  step([$class: 'ArtifactArchiver', artifacts: '**/target/failsafe-reports/test*-output.txt'])
}

def pushToRepo(String serviceName) {
  def gitCommit = getCommitId ()
  sh "docker tag " + serviceName + ":${gitCommit} localhost:${REGISTRY_PORT}/" + serviceName + ":${gitCommit}"
  sh "docker tag " + serviceName + ":${gitCommit} localhost:${REGISTRY_PORT}/" + serviceName + ":latest"
  sh "docker push localhost:${REGISTRY_PORT}/" + serviceName + ":${gitCommit}"
  sh "docker push localhost:${REGISTRY_PORT}/" + serviceName + ":latest"
}

def deploy () {
  sh "kubectl apply -f manifests"
}

def getCommitId () {
  sh 'git rev-parse --short HEAD > git.commit'
  return readFile('git.commit').trim()
}

return this;
