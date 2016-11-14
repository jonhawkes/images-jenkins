// vi: set ft=groovy :
import jenkins.model.*;
import hudson.security.ACL;

NAME = new File(getClass().protectionDomain.codeSource.location.path).name;

Thread.start {
  try {
    def env = System.getenv();

    // Check environment variables.
    ['JENKINS_SLAVE_AGENT_PORT'].each {
      if (env[it] == '') {
        println "--> ${NAME}: You must set ${it}!";
        System.exit(10);
      }
    }

    int port = (env['JENKINS_SLAVE_AGENT_PORT'].toInteger() ?: 5000);

    sleep 10 * 1000;

    println "--> ${NAME}: setting agent port for jnlp";

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      Jenkins.instance.setSlaveAgentPort(port);
    }

    println "--> ${NAME}... DONE";
  } catch (e) {
    println "--> ${NAME}... FAILED: ${e}";
    org.codehaus.groovy.runtime.StackTraceUtils.sanitize(e).printStackTrace();
    System.exit(10);
  }
}
