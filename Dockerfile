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

# Install Amalgam8
RUN apt-get -y install python-pip \
 && pip install git+https://github.com/amalgam8/a8ctl

# Install Gradle 2.10
RUN rm -rf /var/lib/apt/lists/* \
 && echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get -t jessie-backports install -y gradle

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose

 # Install Cloud Foundry CLI (For Bluemix)
RUN curl "https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.22.2&source=github-rel" > /usr/local/bin/cf-cli \
 && chmod +x /usr/local/bin/cf-cli

 # Install Bluemix CLI
RUN cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-linux_x64 \
 && curl "http://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/Bluemix_CLI_0.4.4_amd64.tar.gz" > /usr/local/bin/bx-cli \
 && chmod +x /usr/local/bin/cf-cli

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

COPY liber8-jenkins.sh /usr/local/bin/liber8-jenkins.sh
RUN chmod +x /usr/local/bin/liber8-jenkins.sh

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/liber8-jenkins.sh"]

# EOF
