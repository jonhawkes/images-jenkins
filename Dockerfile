FROM jenkins:2.19.2

ENV   LANG          en_US.UTF-8
ENV   JENKINS_URL   http://localhost:8080/
ENV   GITHUB_NAME   GitHub Enterprise

# 'jenkins' image normally runs as user 'jenkins' but we currently need to be
# root in order to drive the Docker client.
USER root

# Install docker
RUN apt-get update \
 && apt-get -y install apt-transport-https ca-certificates \
 && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
 && echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-cache policy docker-engine \
 && apt-get -y install docker-engine

# Install kubectl
RUN apt-get update \
 && apt-get -y install curl \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install Jenkins plugins and their dependencies.
RUN /usr/local/bin/install-plugins.sh \
\
  # The first block of plugins are needed to make the
  # "updates are available" message go away. Rebuild the container if
  # that message comes back
\
  ant \
  antisamy-markup-formatter \
  build-timeout \
  credentials \
  credentials-binding \
  external-monitor-job \
  email-ext \
  github-organization-folder \
  gradle \
  javadoc \
  junit \
  ldap \
  mailer \
  matrix-auth \
  matrix-project \
  pam-auth \
  script-security \
  ssh-credentials \
  ssh-slaves \
  subversion \
  timestamper \
  translation \
  windows-slaves \
  workflow-aggregator \
  ws-cleanup \
\
  # Allows logging in via GitHub
  github-oauth \
\
  # Pipeline plugins
  docker-workflow \
  pipeline-utility-steps \
  pipeline-maven \
  pipeline-model-definition \
  workflow-remote-loader \
\
  # Build steps and parts
  envinject \
  slack \
  build-user-vars-plugin \
\
  # Pretties and things to make life better
  ansicolor \
  modernstatus \
  embeddable-build-status \
  pegdown-formatter \
  buildtriggerbadge \
  config-file-provider \
  blueocean \
\
  # Handy meta tools
  favorite \
  htmlpublisher \
  lockable-resources \
  parameterized-trigger \
  support-core \
  monitoring \
\
  # Slaves/Pickles
  swarm \
\
  # Analytics
  xunit \
  jacoco \
  pmd \
  findbugs \
  cucumber-reports \
  analysis-core \
\
  # Views
  dashboard-view \
  view-job-filters

# Init and configuration
COPY init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY config.xml /usr/share/jenkins/ref/config.xml

COPY microservicebuilder-jenkins.sh /usr/local/bin/microservicebuilder-jenkins.sh
RUN chmod +x /usr/local/bin/microservicebuilder-jenkins.sh

RUN mkdir /scripts
COPY scripts/buildUtils.groovy /scripts/buildUtils.groovy

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/microservicebuilder-jenkins.sh"]

# EOF
