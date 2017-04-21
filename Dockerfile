FROM jenkins:2.46.1

# Deleting this breaks the chmod +x below
USER root

# JENKINS_URL is required by ghenkins.groovy
ENV   LANG          en_US.UTF-8
ENV   JENKINS_URL   http://localhost:8080/
ENV   GITHUB_NAME   GitHub Enterprise

# Install Jenkins plugins and their dependencies.
RUN /usr/local/bin/install-plugins.sh \
\
  # The first block of plugins are needed to make the
  # "updates are available" message go away. Rebuild the container if
  # that message comes back
  #
  # MN currently removing as many as possible from this list.
  # currently too many commented out: Jenkins comes up with no github integration.
\
  #ant \
  #antisamy-markup-formatter \
  #build-timeout \
  #
  # NEXT: test credentials and cred-binding.
  credentials \
  credentials-binding \
  #external-monitor-job \
  #email-ext \
  github-organization-folder \
  #gradle \
  #javadoc \
  #junit \
  #ldap \
  #mailer \
  # Something in this next block is vital to github-org kicking off. One or more of the first five. One or more of the first 3.
  # one or both of the matrix- plugins are required.
  matrix-auth \
  matrix-project \
  # pam-auth is not required. None of the plugins in the block below are required for github or login.
  #pam-auth \
  #script-security \
  #ssh-credentials \
  #ssh-slaves \
  #timestamper \
  #translation \
  #windows-slaves \
  #workflow-aggregator \
  #ws-cleanup \
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

# Cutting everything out below here breaks ghenkins.groovy:192
# embeddable-build-status is required. At least one other plugin is also required.
\
  # Build steps and parts
  #envinject \
  #slack \
  #build-user-vars-plugin \
#\
  #ansicolor \
  #modernstatus \
\
  # Removing embeddable-build-status breaks ghenkins.groovy:192
  embeddable-build-status \
\
  # pegdown-formatter \
  #buildtriggerbadge \      # These next 3 are not required
  #config-file-provider \
  #blueocean \
#\
  # Handy meta tools - deleting lockableresources breaks ghenkins.groovy:213
  # Deleting just the first 3 has the same effect
  # lockableresources is clearly used in ghenkins.groovy
  #favorite \
  #htmlpublisher \
  lockable-resources
  #parameterized-trigger \  # these next 3 are not required
  #support-core \
  #monitoring
#\       ## Everything below here can be deleted
  # Slaves/Pickles
  #swarm \
#\
  # Analytics
  #xunit \
  #jacoco \
  #pmd \
  #findbugs \
  #cucumber-reports \
  #analysis-core \
#\
  # Views
  #dashboard-view \
  #view-job-filters

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
