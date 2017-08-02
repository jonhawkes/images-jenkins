# Jenkins Pipeline Image
[![Build Status](https://travis.ibm.com/liber8/images-jenkins.svg?token=SLEenfULapEFS7qrDAxj&branch=master)](https://travis.ibm.com/liber8/images-jenkins)

This repository builds Jenkins in a Docker container. Administrative access to the Jenkins server is via IBM intranet password. You only need to log into the server in order to manually trigger builds or to change the server configuration.

You can download a stable version of this image from Artifactory. You must first login and the pull down the image with the following commands:

```
docker login wasliberty-liber8-docker.artifactory.swg-devops.com -u <IBM intranet ID> -p <IBM intranet password>
docker pull --all-tags wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins
```

By default the server will automatically build all branches on all repositories in the liber8-pipeline-test organisation. Add additional organisations by adding comma separated value to this entry in the `docker.env` file:

```
GITHUB_ORGS=liber8-pipeline-test
```

If you need to build images-jenkins yourself you can do so:

``` sh
$ docker build -t jenkins .
```

See [pipeline](https://github.ibm.com/liber8/pipeline) for more instructions on the use of this component.

# Debugging Jenkins plugins

References - [Jenkins Plugin tutorial](https://wiki.jenkins.io/display/JENKINS/Plugin+tutorial) & Simpson, D. (2015). *Extending Jenkins*. Birmingham: PACKT, Chapter 8.

If you need to debug a Jenkins plugin for any reason I would strongly recommend using [NetBeans](https://netbeans.org/downloads/). This IDE has the strongest support for debugging Jenkins and is easier to use, and for me has had much more consistent results.

*NOTE: You may be presented with errors upon loading a project in your IDE. It is safe to ignore these; the guide will work regardless.*

*When you make changes to view files in `src/main/resources` or resource files in `src/main/webapp`, just save the file and refresh your browser to see the changes.
When you change Java source files, compile them in your IDE (NetBeans 6.7+: Debug > Apply Code Changes) and Jetty should automatically redeploy Jenkins to pick up those changes. There is no need to run `mvn` at all.*

## Debugging with NetBeans

1. Go to `Tools > Plugins > Available plugins` and type "Jenkins" into the search bar
2. Install "Jenkins Plugin Support" and "Stapler Support" (this should also install "Yenta API")
3. Import the project into NetBeans (`File > Open Project`)
4. Set any breakpoints necessary
5. Right click the project in the "Projects" view and click `Debug`. This will pull down a fresh version of Jenkins to your `.m2` folder (on my Windows system this is located at `C:\Users\<USER_NAME>\.m2\repository\org\jenkins-ci\main\jenkins-war\1.642.3\jenkins-war-1.642.3.war`) with your project compiled and applied as a plugin. *Changes you make to this Jenkins instance (e.g. installing additional plugins) will persist as long as the project is loaded in the IDE and the `target` dir remains intact.* Additional files will also be located in `<PLUGIN_NAME>/target/tmp/webapp`. You will be able to view console output in NetBeans and when a breakpoint is reached the focus will switch to NetBeans and bring up the debug interface, showing variables and other useful debugging information.

## Debugging with Eclipse

*Use Eclipse Juno (4.2) or later for the best experience.
Eclipse versions between 4.5 and < 4.6.2 contain a bug that causes errors such as "Only a type can be imported. hudson.model.Job resolves to a package".
If you encounter this error please upgrade to Eclipse Neon.2 (4.6.2) or higher.*

1. Import the project into Eclipse. Don't use the "Import existing Maven projects" option as using M2E is not recommended for Jenkins plugins. The (retired) [Maven Eclipse plugin](http://maven.apache.org/plugins/maven-eclipse-plugin/) is recommended unless you have prior experience with M2E. Instead use `File > Import > General > Existing projects into workspace`
2. Set any breakpoints necessary
3. Right click the project and select `Debug as > Maven build...`. Enter `hpi:run` into "goals" and then click "Debug".
4. This will pull down a fresh version of Jenkins to your `.m2` folder (on my Windows system this is located at `C:\Users\<USER_NAME>\.m2\repository\org\jenkins-ci\main\jenkins-war\1.642.3\jenkins-war-1.642.3.war`) with your project compiled and applied as a plugin. *Changes you make to this Jenkins instance (e.g. installing additional plugins) will persist as long as the project is loaded in the IDE and the `target` dir remains intact.* Additional files will also be located in `<PLUGIN_NAME>/target/tmp/webapp`. You should be able to view console output in Eclipse and when a breakpoint is reached the focus *should* switch to Eclipse and bring up the debug interface, showing variables and other useful debugging information.

## Debugging with the command line

1. You can also debug from the command line.
- For Unix: `$ export MAVEN_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"`. 
- For Windows (bash): `> set MAVEN_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n`.
- Then run `mvnDebug hpi:run`. This should start up Maven in debug mode with a listener on localhost:8000 (depending on your settings) due to the MAVEN_OPTS option. 
2. You will now be able to connect a debug session to this port in your IDE. For example, in Eclipse, select `Run > Debug Configurations...`. You should then be able to select `Remote Java Application` from the left hand side of the new window, ensuring it matches the correct application, and then click `Debug`. Ensure that you give this configuration a name to prevent errors.

