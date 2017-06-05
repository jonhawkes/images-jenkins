#!/bin/bash
#
###########################################################################
# (C) Copyright IBM Corporation 2016.                                     #
#                                                                         #
# Licensed under the Apache License, Version 2.0 (the "License");         #
# you may not use this file except in compliance with the License.        #
# You may obtain a copy of the License at                                 #
#                                                                         #
#      http://www.apache.org/licenses/LICENSE-2.0                         #
#                                                                         #
# Unless required by applicable law or agreed to in writing, software     #
# distributed under the License is distributed on an "AS IS" BASIS,       #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
# See the License for the specific language governing permissions and     #
# limitations under the License.                                          #
###########################################################################

#Copy credentials into docker.env file
echo "Copying credential into docker.env file for Jenkins-GHE connectivity"
sed -i -e 's/GITHUB_APP_ID=your.app.id/GITHUB_APP_ID='${APP_ID}'/g' docker.env
sed -i -e 's/GITHUB_APP_SECRET=your.app.secret/GITHUB_APP_SECRET='${APP_SECRET}'/g' docker.env
sed -i -e 's/GITHUB_OAUTH_USER=your.userid/GITHUB_OAUTH_USER='${OAUTH_USER}'/g' docker.env
sed -i -e 's/GITHUB_OAUTH_TOKEN=your.oauth.token/GITHUB_OAUTH_TOKEN='${OAUTH_TOKEN}'/g' docker.env
sed -i -e 's/GITHUB_ADMINS=your.userid/GITHUB_ADMINS='${ADMIN}'/g' docker.env

#Download the license zip file
echo "Downloading the license zip"
curl -u${USERNAME}:${PASSWORD} -O "https://na.artifactory.swg-devops.com/artifactory/wasliberty-liber8-generic/2017.01.beta/license/Text.zip"
rm -r lafiles
unzip Text.zip
mv Text lafiles

#Building the Jenkins image
echo "Building the Jenkins image"
docker build --no-cache -t microservicebuilder-jenkins .

#Create the network
docker network create fabriccompose_default

#Run the jenkins image images
echo "Deploying the image"
docker-compose up -d

#Test the image has been deployed via http response
echo "Test the HTTP port for a 200 response"
sleep 50
starttime=$SECONDS
while (($SECONDS < $starttime+60)) ; do
  if curl --output /dev/null --silent --head --fail "localhost:8080"; then
  echo "Jenkins is up and running"
  break
  else
  echo "Jenkins is not up and running"
  sleep 3
 fi
done

#Test the logs output for a success
echo "Test the logs for the container"
sleep 40
docker logs microservicebuilder-jenkins 2>&1 | grep -qi 'Jenkins is fully up and running'
  if [[ $? == 0 ]]; then
     echo "Test passed"
  else
     echo "Test failed, could not find the message Jenkins is fully up and running"
     echo "Displaying logs from the jenkins container"
     docker logs microservicebuilder-jenkins
     exit 1
  fi
#Test that the plugins installed correctly
echo "Test the logs to see "
docker logs microservicebuilder-jenkins 2>&1 | grep -qi 'Failed Loading plugin'
  if [[ $? == 0 ]]; then
     echo "Test failed, some plugins failing to load"
     echo "Displaying logs from the jenkins container"
     docker logs microservicebuilder-jenkins
     exit 1
  else
     echo "Test passed"
  fi

#Bring down the container
echo "Stopping the container"
docker-compose down
