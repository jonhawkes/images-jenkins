import groovy.util.logging.Log;
import jenkins.model.Jenkins;
import jenkins.plugins.git.GitSCMSource;
import org.jenkinsci.plugins.workflow.libs.*;

@Log
class AddLibraries {

  public invoke () {
    log.info 'into addLibraries'

    def pipelineTemplateLocation = System.getenv("PIPELINE_TEMPLATE_LOCATION");
    def pipelineTemplateDefaultVersion = System.getenv("PIPELINE_TEMPLATE_DEFAULT_VERSION");

    log.info "Load pipeline template from ${pipelineTemplateLocation} with default version ${pipelineTemplateDefaultVersion}"

    GitSCMSource source = new GitSCMSource (
      "msb.lib", 
      pipelineTemplateLocation, 
      "github-oauth-userpass", 
      "*", 
      "", 
      false)
    SCMSourceRetriever retriever = new SCMSourceRetriever (source);
    LibraryConfiguration libconfig = new LibraryConfiguration("MicroserviceBuilder", retriever)
    libconfig.setDefaultVersion (pipelineTemplateDefaultVersion)
    libconfig.setImplicit(true)
    def jenkinsInst = Jenkins.getInstance()
    def jenkinsDesc = jenkinsInst.getDescriptor("org.jenkinsci.plugins.workflow.libs.GlobalLibraries")
    jenkinsDesc.get().setLibraries([libconfig])
    jenkinsDesc.save()

    log.info "addLibraries complete."
  }

}

new AddLibraries().invoke();
