FROM jenkins:2.60.2

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
    ace-editor:1.1 \
    authentication-tokens:1.3 \
    bouncycastle-api:2.16.2 \
    branch-api:2.0.11 \
    cloudbees-folder:6.1.0 \
    credentials-binding:1.12 \
    credentials:2.1.14 \
    display-url-api:2.0 \
    docker-commons:1.8 \
    docker-workflow:1.12 \
    durable-task:1.14 \
    embeddable-build-status:1.9 \
    git-client:2.4.6 \
    git-server:1.7 \
    git:3.4.1 \
    github-api:1.86 \
    github-branch-source:2.2.2 \
    github-oauth:0.27 \
    github:1.27.0 \
    handlebars:1.1.1 \
    icon-shim:2.0.3 \
    jackson2-api:2.7.3 \
    jquery-detached:1.2.1 \
    junit:1.20 \
    kubernetes:0.11 \
    lockable-resources:2.0 \
    mailer:1.20 \
    matrix-auth:1.7 \
    matrix-project:1.11 \
    momentjs:1.1.1 \
    pipeline-build-step:2.5.1 \
    pipeline-github-lib:1.0 \
    pipeline-graph-analysis:1.4 \
    pipeline-input-step:2.7 \
    pipeline-milestone-step:1.3.1 \
    pipeline-model-api:1.1.9 \
    pipeline-model-declarative-agent:1.1.1 \
    pipeline-model-definition:1.1.9 \
    pipeline-model-extensions:1.1.9 \
    pipeline-rest-api:2.8 \
    pipeline-stage-step:2.2 \
    pipeline-stage-tags-metadata:1.1.9 \
    pipeline-stage-view:2.8 \
    plain-credentials:1.4 \
    scm-api:2.2.0 \
    script-security:1.30 \
    ssh-credentials:1.13 \
    structs:1.9 \
    token-macro:2.1 \
    workflow-aggregator:2.5 \
    workflow-api:2.19 \
    workflow-basic-steps:2.6 \
    workflow-cps-global-lib:2.8 \
    workflow-cps:2.37 \
    workflow-durable-task-step:2.13 \
    workflow-job:2.12.1 \
    workflow-multibranch:2.16 \
    workflow-scm-step:2.6 \
    workflow-step-api:2.12 \
    workflow-support:2.14

# Init and configuration
COPY init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY config.xml /usr/share/jenkins/ref/
COPY jenkins.CLI.xml /usr/share/jenkins/ref/

COPY microservicebuilder-jenkins.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/microservicebuilder-jenkins.sh

# Copy the license files
COPY lafiles /microservicebuilder/

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/microservicebuilder-jenkins.sh"]

# EOF
