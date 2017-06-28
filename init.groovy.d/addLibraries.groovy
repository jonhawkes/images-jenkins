import groovy.util.logging.Log;
import hudson.plugins.git.*;
import hudson.scm.SCM;
import jenkins.model.*;
import org.jenkinsci.plugins.workflow.libs.*

@Log
class AddLibraries {

  public invoke () {
    log.info 'into addLibraries'

    def templateName = "MicroserviceBuilder"
    def defaultLibraryVersion = "master" // default git tag / version
    def pipelineTemplateLocation = System.getenv("PIPELINE_TEMPLATE_LOCATION");
    def pipelineTemplateDefaultVersion = System.getenv("PIPELINE_TEMPLATE_DEFAULT_VERSION");

    log.info "Load pipeline template from ${pipelineTemplateLocation} with default version ${pipelineTemplateDefaultVersion}"
    SCM scm = new GitSCM(pipelineTemplateLocation)

    SCMRetriever retriever = new SCMRetriever(scm)
    LibraryConfiguration libconfig = new LibraryConfiguration(templateName, retriever)
    libconfig.setDefaultVersion (pipelineTemplateDefaultVersion)
    def jenkinsInst = Jenkins.getInstance()
    def jenkinsDesc = jenkinsInst.getDescriptor("org.jenkinsci.plugins.workflow.libs.GlobalLibraries")
    jenkinsDesc.get().setLibraries([libconfig])
    jenkinsDesc.save()

    log.info 'addLibraries complete'

  }

}

new AddLibraries().invoke();
