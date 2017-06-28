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

#Remove local images
function delete() {
  docker rmi mb-jenkins:latest
  docker rmi wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:latest
  docker rmi wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:$TRAVIS_COMMIT
}

#Download latest images
function pull() {
  docker login wasliberty-liber8-docker.artifactory.swg-devops.com -u $USERNAME -p $PASSWORD
  docker pull wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:latest
  docker pull wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:$TRAVIS_COMMIT
}

#Test image with latest as tag
delete
pull
#Tag image to test
docker tag wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:latest mb-jenkins:latest
./test/test.sh
#Test image with commit id as tag
docker tag wasliberty-liber8-docker.artifactory.swg-devops.com/mb-jenkins:$TRAVIS_COMMIT mb-jenkins:latest
./test/test.sh
