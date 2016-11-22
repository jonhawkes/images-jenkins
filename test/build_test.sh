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
cd ..
sed -i -e 's/GITHUB_APP_ID=/GITHUB_APP_ID='${APP_ID}'/g' docker.env
sed -i -e 's/GITHUB_APP_SECRET=/GITHUB_APP_SECRET='${APP_SECRET}'/g' docker.env
sed -i -e 's/GITHUB_OAUTH_USER=/GITHUB_OAUTH_USER='${OAUTH_USER}'/g' docker.env
sed -i -e 's/GITHUB_OAUTH_TOKEN=/GITHUB_OAUTH_TOKEN='${OAUTH_TOKEN}'/g' docker.env
sed -i -e 's/GITHUB_ADMINS=/GITHUB_ADMINS='${ADMIN}'/g' docker.env

#Building the Jenkins image
echo "Building the Jenkins image"
docker build -t jenkins .

#Create the network
docker network create fabric_default

#Run the jenkins image images
echo "Deploying the image"
docker-compose up -d

#Test the image has been deployed via http response
echo "Test the HTTP port for a 200 response"
sleep 50
starttime=$SECONDS
while (($SECONDS < $starttime+30)) ; do
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
sleep 30
docker logs liber8-jenkins 2>&1 | grep -qi 'Jenkins is fully up and running'
  if [[ $? == 0 ]]; then
     echo "Test passed"
  else
     echo "Test failed"
  fi

#Bring down the container
echo "Stopping the container"
docker-compose down

#Push the new Jenkins image to Artifactory
docker login wasliberty-liber8-docker.artifactory.swg-devops.com -u $USERNAME -p $PASSWORD
docker tag liber8-jenkins:devel wasliberty-liber8-docker.artifactory.swg-devops.com/liber8-jenkins:latest
docker push wasliberty-liber8-docker.artifactory.swg-devops.com/liber8-jenkins:latest