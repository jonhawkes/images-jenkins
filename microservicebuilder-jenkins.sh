#!/bin/bash

set -euo pipefail

: ${JAVA_OPTS:=}

if [ "$JAVA_OPTS" != *-Dhudson.security.ArtifactsPermission* ]; then
  JAVA_OPTS="${JAVA_OPTS} -Dhudson.security.ArtifactsPermission=true"
fi
JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
JAVA_OPTS="${JAVA_OPTS} -Djava.util.logging.SimpleFormatter.format='[%1\$tF %1\$tT]:%4\$s:(%2\$s): %5\$s%n'"

echo '--> This product is a beta and cannot be used in production. The full license terms can be viewed here: https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/microservicebuilder/license/2017.01.beta/en.html'

echo '--> Clearing out plugins provided by container...'
for plugin_path in /usr/share/jenkins/ref/plugins/*.jpi; do
  plugin=$(basename "$plugin_path" .jpi)
  rm -rf "${JENKINS_HOME}/plugins/${plugin}"
  rm -vf  "${JENKINS_HOME}/plugins/${plugin}".[jh]pi*
done

echo '--> Clearing out old init groovy...'
rm -rf "${JENKINS_HOME}/init.groovy.d"
mkdir -p "${JENKINS_HOME}/init.groovy.d"

echo -n "$JENKINS_VERSION" > "${JENKINS_HOME}/jenkins.install.UpgradeWizard.state"
echo -n "$JENKINS_VERSION" > "${JENKINS_HOME}/jenkins.install.InstallUtil.lastExecVersion"

exec "/usr/local/bin/jenkins.sh" "$@"
