# Jenkins Pipeline Image

This repository builds Jenkins in a Docker container. Administrative access to the Jenkins server is via IBM intranet password. You only need to log into the server in order to manually trigger builds or to change the server configuration. 

By default the server will automatically build all branches on all repositories in the liber8-pipeline-test organisation. Add additional organisations by adding comma separated value to this entry in the `docker.env` file:

```
GITHUB_ORGS=liber8-pipeline-test
```

If you need to log into the Jenkins server then you must add your authentification details into the docker.env file in this directory. Follow the [instructions on the GHEnkins page to setup the application id and user OAuth tokens](https://github.ibm.com/tron/ghenkins-docker#user-content-getting-the-application-id).

  Add these values to the `docker.env` file:

  App id and secret:
  ```
  GITHUB_APP_ID=
  GITHUB_APP_SECRET=
  ```

  User OAuth user and token. The User can just be your GHE (shortname) id:
  ```
  GITHUB_OAUTH_USER=
  GITHUB_OAUTH_TOKEN=
  ```

  Jenkins admin user id. Should be the same as your GHE (shortname) id:
  ```
  GITHUB_ADMINS=
  ```

Build the Jenkins image:
``` sh
$ docker build -t jenkins .
```

The Jenkins image will normally be started from the 'pipeline' project. However if you wish to run it from here you can:
``` sh
$ docker-compose up
```
