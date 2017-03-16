def version='1.0'

def mavenBuild(String ... args) {
  withMaven(
      maven: 'M3',
      mavenLocalRepo: '.repository') {
    sh "mvn -B " + args.join (' ')
  }
}

def dockerBuild(String appName) {
  def gitCommit = getCommitId ()
  sh "docker build -t ${appName}:${gitCommit} ."

  def registry = "${REGISTRY}".trim()
  if (registry) {
    if (!registry.endsWith('/')) {
      registry = "${registry}/"
    }
    sh "docker tag ${appName}:${gitCommit} ${registry}${appName}:${gitCommit}"
    sh "docker push ${registry}${appName}:${gitCommit}"
  }

  // If yaml is deploying image:latest, change it to image:gitCommit
  // Also add ${registry} prefix. This is harmless if there is no registry.
  sh "find manifests -type f | xargs sed -i \'s|${appName}:latest|${registry}${appName}:${gitCommit}|g\'"

}

def deploy () {
  sh "kubectl apply -f manifests"
}

def getCommitId () {
  sh 'git rev-parse --short HEAD > git.commit'
  return readFile('git.commit').trim()
}

return this;
