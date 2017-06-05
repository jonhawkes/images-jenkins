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
