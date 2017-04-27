FROM jenkins:2.46.2

# Deleting this breaks the chmod +x below
USER root

# JENKINS_URL is required by ghenkins.groovy
ENV   LANG          en_US.UTF-8
ENV   JENKINS_URL   http://localhost:8080/
ENV   GITHUB_NAME   GitHub Enterprise

# Install Jenkins plugins and their dependencies.
RUN /usr/local/bin/install-plugins.sh \
\
  # Install plugins required for git, github oauth, github-org, kubernetes and pipeline.
  # Kubernetes integration from https://github.com/kubernetes/charts/stable/jenkins
  # Some plugins are required to keep ghenkins.groovy happy.
  #
  credentials-binding:1.11 \
  embeddable-build-status \
  git:3.3.0 \
  github-oauth \
  github-organization-folder \
  kubernetes:0.11 \
  lockable-resources \
  matrix-auth \
  matrix-project \
  workflow-aggregator:2.5

# Init and configuration
COPY init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY config.xml /usr/share/jenkins/ref/config.xml

COPY microservicebuilder-jenkins.sh /usr/local/bin/microservicebuilder-jenkins.sh
RUN chmod +x /usr/local/bin/microservicebuilder-jenkins.sh

RUN mkdir /scripts
COPY scripts/buildUtils.groovy /scripts/buildUtils.groovy

# Copy the license files
# COPY lafiles /microservicebuilder/

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/microservicebuilder-jenkins.sh"]

# EOF
