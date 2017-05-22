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
    ace-editor:1.1 \
    authentication-tokens:1.3 \
    branch-api:2.0.9 \
    cloudbees-folder:6.0.4 \
    credentials-binding:1.11 \
    credentials:2.1.13 \
    display-url-api:2.0 \
    docker-commons:1.6 \
    docker-workflow:1.10 \
    durable-task:1.13 \
    embeddable-build-status:1.9 \
    git-client:2.4.5 \
    git-server:1.7 \
    git:3.3.0 \
    github-api:1.85 \
    github-branch-source:2.0.5 \
    github-oauth:0.27 \
    github-organization-folder:1.6 \
    github:1.27.0 \
    handlebars:1.1 \
    icon-shim:2.0.3 \
    jquery-detached:1.2.1 \
    junit:1.20 \
    kubernetes:0.11 \
    lockable-resources:2.0 \
    mailer:1.20 \
    matrix-auth:1.5 \
    matrix-project:1.10 \
    momentjs:1.1.1 \
    pipeline-build-step:2.5 \
    pipeline-github-lib:1.0 \
    pipeline-graph-analysis:1.3 \
    pipeline-input-step:2.7 \
    pipeline-milestone-step:1.3.1 \
    pipeline-model-api:1.1.4 \
    pipeline-model-declarative-agent:1.1.1 \
    pipeline-model-definition:1.1.4 \
    pipeline-model-extensions:1.1.4 \
    pipeline-rest-api:2.6 \
    pipeline-stage-step:2.2 \
    pipeline-stage-tags-metadata:1.1.4 \
    pipeline-stage-view:2.6 \
    plain-credentials:1.4 \
    scm-api:2.1.1 \
    script-security:1.27 \
    ssh-credentials:1.13 \
    structs:1.6 \
    token-macro:2.1 \
    workflow-aggregator:2.5 \
    workflow-api:2.13 \
    workflow-basic-steps:2.4 \
    workflow-cps-global-lib:2.8 \
    workflow-cps:2.30 \
    workflow-durable-task-step:2.11 \
    workflow-job:2.10 \
    workflow-multibranch:2.14 \
    workflow-scm-step:2.4 \
    workflow-step-api:2.9 \
    workflow-support:2.14

# Init and configuration
COPY init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY config.xml /usr/share/jenkins/ref/config.xml

COPY microservicebuilder-jenkins.sh /usr/local/bin/microservicebuilder-jenkins.sh
RUN chmod +x /usr/local/bin/microservicebuilder-jenkins.sh

# Copy the license files
# COPY lafiles /microservicebuilder/

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/microservicebuilder-jenkins.sh"]

# EOF
