def version='1.0'

def mavenBuild(String ... args) {
  def mvnHome = tool 'M3'
  sh "${mvnHome}/bin/mvn -B -DbuildId=$BUILD_ID " + args.join (' ')
  sh "echo Build ID = $BUILD_ID"
}

def mavenVerify () {
  def mvnHome = tool 'M3'
  sh "${mvnHome}/bin/mvn verify"
  step([$class: 'JUnitResultArchiver', testResults: '**/target/failsafe-reports/TEST-*.xml'])
  step([$class: 'ArtifactArchiver', artifacts: '**/target/failsafe-reports/test*-output.txt'])
}

def pushToRepo(String serviceName) {
  sh "docker tag " + serviceName + ":$BUILD_ID localhost:31500/" + serviceName + ":$BUILD_ID"
  sh "docker tag " + serviceName + ":$BUILD_ID localhost:31500/" + serviceName + ":latest"
  sh "docker push localhost:31500/" + serviceName + ":$BUILD_ID"
  sh "docker push localhost:31500/" + serviceName + ":latest"
}

def dockerBuild(String appName) {
  sh "docker build -t " + appName + " ."
}

def deploy () {
  sh "kubectl apply -f manifests"
}



return this;
