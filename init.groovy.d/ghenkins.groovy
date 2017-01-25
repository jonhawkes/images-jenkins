// vi: set ft=groovy :

// Useful links:
//  * http://javadoc.jenkins-ci.org/
//  * https://gist.github.com/xbeta/e5edcf239fcdbe3f1672
//  * https://github.com/jenkinsci/puppet-jenkins/blob/master/files/puppet_helper.groovy

import hudson.security.ACL;
import hudson.security.Permission;
import jenkins.model.Jenkins;
import groovy.util.logging.Log;
import com.cloudbees.plugins.credentials.domains.Domain;
import com.cloudbees.plugins.credentials.CredentialsScope;
import com.cloudbees.plugins.credentials.CredentialsMatchers;
import com.cloudbees.plugins.credentials.common.StandardCredentials;

import hudson.triggers.TimerTrigger;
import jenkins.branch.OrganizationFolder;
import org.jenkinsci.plugins.github_branch_source.Endpoint;
import org.jenkinsci.plugins.github_branch_source.GitHubConfiguration;
import org.jenkinsci.plugins.github_branch_source.GitHubSCMNavigator;

@Log
class GhenkinsSetup
{
  public invoke() {
    try {
      log.info "Starting...";
      checkRequiredEnvVars();

      setupLocation();
      setupSecurityRealm();
      setupAuthorizationStrategy();
      setupAdmin();
      createUserPassCredential();
      createTokenCredential();

      configGithubApi();
      setupOrgFolders();

      setupSlaveSecurity();
      setupMasterNode();
      log.info "Finished!";
    } catch (e) {
      log.severe "FAILED: ${e}";
      org.codehaus.groovy.runtime.StackTraceUtils.sanitize(e).printStackTrace();
      System.exit(10);
    }
  }

  public checkRequiredEnvVars() {
    def env = System.getenv();
    def ok = true;
    [
      'JENKINS_URL',
      'JENKINS_EMAIL',
      'GITHUB_URL',
      'GITHUB_NAME',
      'GITHUB_APP_ID',
      'GITHUB_APP_SECRET',
      'GITHUB_OAUTH_USER',
      'GITHUB_OAUTH_TOKEN',
      'GITHUB_ADMINS'
    ].each {
      if (env[it] == null || env[it] == '') {
        log.severe "You must set the environment variable ${it}!";
        ok = false;
      }
    }
    if (!ok) {
      System.exit(10);
    }
  }

  public String jenkinsUrl() {
    return System.getenv('JENKINS_URL');
  }

  public String jenkinsEmail() {
    return System.getenv('JENKINS_EMAIL');
  }

  public String githubName() {
    return System.getenv('GITHUB_NAME');
  }

  public String githubOauthUser() {
    return System.getenv('GITHUB_OAUTH_USER');
  }

  public String githubOauthToken() {
    return System.getenv('GITHUB_OAUTH_TOKEN');
  }

  public String githubUrl() {
    return System.getenv('GITHUB_URL') - ~/\/+$/;
  }

  public String githubApiUrl() {
    def url = githubUrl();
    if (url == 'https://github.com') {
      return 'https://api.github.com';
  } else {
    return "${url}/api/v3";
  }
  }

  public String githubAppId() {
    return System.getenv('GITHUB_APP_ID');
  }

  public String githubAppSecret() {
    return System.getenv('GITHUB_APP_SECRET');
  }

  public List<String> githubAdmins() {
    return System.getenv('GITHUB_ADMINS').tokenize(',');
  }

  public List<String> githubOrganizations() {
    def envOrgs = System.getenv('GITHUB_ORGS');
    if (envOrgs == null || envOrgs == '') {
      return [];
    }

    return envOrgs.tokenize(',');
  }

  public String githubRepoNamePattern() {
    return System.getenv('GITHUB_REPO_PATTERN') ?: ".*";
  }

  public String adminSshKey() {
    return System.getenv('ADMIN_SSH_KEY');
  }

  public setupLocation() {
    log.info "Setting Jenkins location...";
    def location = jenkins.model.JenkinsLocationConfiguration.get();
    location.setUrl(jenkinsUrl());
    location.setAdminAddress(jenkinsEmail());
    location.save();
  }

  public setupSecurityRealm() {
    log.info "Setting up security realm...";

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      Jenkins.instance.setDisableRememberMe(true);

      def realm = new org.jenkinsci.plugins.GithubSecurityRealm(
          githubUrl(),
          githubApiUrl(),
          githubAppId(),
          githubAppSecret(),
          "read:org,user:email"
          );

      if(!realm.equals(Jenkins.instance.getSecurityRealm())) {
        Jenkins.instance.setSecurityRealm(realm);
        Jenkins.instance.save();
      }

    }
  }

  static buildNewAccessList(userOrGroup, permissions) {
    def newPermissionsMap = [:];
    permissions.each {
      newPermissionsMap.put(Permission.fromId(it), userOrGroup)
    }
    return newPermissionsMap
  }

  public setupAuthorizationStrategy() {
    log.info "Setting up authorization strategy...";

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      def strategy = new hudson.security.GlobalMatrixAuthorizationStrategy();
      strategy.add(hudson.model.Hudson.ADMINISTER, "ghenkins-admin");
      def organizations = githubOrganizations();
      def orgs_plus = organizations + [ 'anonymous', 'authenticated' ];

      orgs_plus.each { user ->
        buildNewAccessList(user, [
            'hudson.model.Hudson.Read',
            'hudson.model.Item.Discover',
            'hudson.model.Item.Read',
            'hudson.model.Item.ViewStatus',
            'hudson.model.Run.Artifacts',
            'hudson.model.View.Read'
        ]).each { p, u -> strategy.add(p, u) };
      }

      githubAdmins().each { admin ->
        buildNewAccessList(admin, ['hudson.model.Hudson.Administer']).each { p, u -> strategy.add(p, u) };
      }

      organizations.each { organization ->
        buildNewAccessList(organization, [
            'com.cloudbees.plugins.credentials.CredentialsProvider.View',
            'hudson.model.Computer.Connect',
            'hudson.model.Computer.Disconnect',
            'hudson.model.Item.Build',
            'hudson.model.Item.Cancel',
            'hudson.model.Item.Workspace',
            'hudson.model.Run.Delete',
            'hudson.model.Run.Replay',
            'hudson.model.Run.Update',
            'hudson.scm.SCM.Tag',
            'org.jenkins.plugins.lockableresources.LockableResourcesManager.Reserve',
            'org.jenkins.plugins.lockableresources.LockableResourcesManager.Unlock'
        ]).each { p, u -> strategy.add(p, u) };
      }

      if (!strategy.equals(Jenkins.instance.getAuthorizationStrategy())) {
        Jenkins.instance.setAuthorizationStrategy(strategy);
        Jenkins.instance.save();
      }
    }
  }

  public setupAdmin() {
    // log.info "Setting up ghenkins-admin...";
    // // TODO: This should generate the ssh public and private key if it doesn't exist already.
    // hudson.security.ACL.impersonate(ACL.SYSTEM) {
    //   def user = hudson.model.User.get('ghenkins-admin');
    //   user.setFullName('Ghenkins Admin');
    //   def keys = new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(adminSshKey());
    //   user.addProperty(keys);
    //   user.save();
    // }
  }

  public StandardCredentials findCredentialsById(String id, Domain domain=Domain.global()) {
    def idMatcher = CredentialsMatchers.withId(id);
    def credStore = Jenkins.getInstance().getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
        )[0].getStore();
    def allCreds = credStore.getCredentials(domain);

    return CredentialsMatchers.firstOrNull(allCreds, idMatcher);
  }

  public createUserPassCredential() {
    log.info 'Setting up User/Pass Credential';

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      def domain = Domain.global();
      def credentials_store = Jenkins.instance.getExtensionList(
          'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
          )[0].getStore();

      def userpass_credential = new com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl(
          CredentialsScope.GLOBAL,
          'github-oauth-userpass',
          "User/Pass for ${githubName()}",
          githubOauthUser(),
          githubOauthToken(),
          );

      def existing_credentials = findCredentialsById(userpass_credential.id, domain);

      if(existing_credentials != null) {
        credentials_store.updateCredentials(domain, existing_credentials, userpass_credential);
      } else {
        credentials_store.addCredentials(domain, userpass_credential);
      }
    }
  }

  public createTokenCredential() {
    log.info 'Setting up Token Credential';

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      def domain = Domain.global();
      def credentials_store = Jenkins.instance.getExtensionList(
          'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
          )[0].getStore();
      def secret = hudson.util.Secret.fromString githubOauthToken();

      def token_credential = new org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl(
          CredentialsScope.GLOBAL,
          'github-oauth-token',
          "Token for ${githubName()}",
          secret
          );

      def existing_credentials = findCredentialsById(token_credential.id, domain);

      if(existing_credentials != null) {
        credentials_store.updateCredentials(domain, existing_credentials, token_credential);
      } else {
        credentials_store.addCredentials(domain, token_credential);
      }
    }
  }

  public setupSlaveSecurity() {
    log.info 'Setting up Slave to Master Security';

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      def s2mConfig = jenkins.model.GlobalConfiguration.all().get(jenkins.security.s2m.MasterKillSwitchConfiguration.class);
      s2mConfig.rule.setMasterKillSwitch(false);
    }
  }

  public setupMasterNode() {
    log.info 'Configuring the Master node';

    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      Jenkins.instance.setNumExecutors(20);
      Jenkins.instance.setMode(hudson.model.Node.Mode.EXCLUSIVE);
      Jenkins.instance.save();
    }
  }

  public configGithubApi() {
    log.info "Configuring GitHub API Endpoint...";
    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      def config = GitHubConfiguration.get();
      def endpoint = new Endpoint(githubApiUrl(), githubName());

      config.setEndpoints([endpoint]);
    }
  }

  public setupOrgFolders() {
    log.info "Setting up GitHub organization folders...";
    hudson.security.ACL.impersonate(ACL.SYSTEM) {
      githubOrganizations().each { orgName ->
        def existingJob = Jenkins.instance.items.find { it.name == orgName };
        log.info "  org: $orgName";
        if (existingJob == null) {
          def orgFolder = Jenkins.instance.createProject(OrganizationFolder.class, orgName);
          def navigator = new GitHubSCMNavigator(githubApiUrl(), orgName, "github-oauth-userpass", "SAME");
          def pattern = githubRepoNamePattern()
          log.info "  repo pattern: $pattern";
          navigator.setPattern(pattern);
          orgFolder.getNavigators().push(navigator);
          orgFolder.save();
          orgFolder.scheduleBuild(10, new TimerTrigger.TimerTriggerCause());
        } else {
          existingJob.scheduleBuild(10, new TimerTrigger.TimerTriggerCause());
        }
      }
    }
  }

} // End Class GhenkinsSetup

// MAIN
new GhenkinsSetup().invoke();

// EOF
