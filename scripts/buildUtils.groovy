def version='1.0'

def mavenBuild(String ... args) {
  def mvnHome = tool 'M3'
  def gitCommit = getCommitId()
  sh "${mvnHome}/bin/mvn -B -Dtag=${gitCommit} " + args.join (' ')
  sh "echo Commit ID = ${gitCommit}"
}

def mavenVerify () {
  def mvnHome = tool 'M3'
  sh "${mvnHome}/bin/mvn verify"
  step([$class: 'JUnitResultArchiver', testResults: '**/target/failsafe-reports/TEST-*.xml'])
  step([$class: 'ArtifactArchiver', artifacts: '**/target/failsafe-reports/test*-output.txt'])
}

def pushToRepo(String appName) {
  def gitCommit = getCommitId ()
  def registryEnv = "${REGISTRY}"
  def registry
  if (registryEnv?.trim()) {
    registry = "${registry}/"
  } else {
    registry = ""
  }
  sh "docker tag ${appName}:${gitCommit} ${registry}${appName}:${gitCommit}"
  sh "docker tag ${appName}:${gitCommit} ${registry}${appName}:latest"
  sh "docker push ${registry}${appName}:${gitCommit}"
  sh "docker push ${registry}${appName}:latest"
}

def dockerBuild(String appName) {
  def gitCommit = getCommitId ()
  sh "docker build -t ${appName}:${gitCommit} ."
}

def deploy () {
  sh "kubectl apply -f manifests"
}

def getCommitId () {
  sh 'git rev-parse --short HEAD > git.commit'
  return readFile('git.commit').trim()
}

return this;
