#!/bin/bash
#
###########################################################################
# (C) Copyright IBM Corporation 2017.                                     #
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
curl -u${USERNAME}:${PASSWORD} -O "https://na.artifactory.swg-devops.com/artifactory/wasliberty-liber8-generic/1.0.0/license/Text.zip"
rm -r lafiles
unzip Text.zip
mv Text lafiles

#Building the Jenkins image
echo "Building the Jenkins image"
docker build --no-cache -t mb-jenkins .

#Create the network
docker network create fabriccompose_default

#Run the jenkins image tests
./test/test.sh
