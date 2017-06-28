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


function test() {
  #Run the jenkins image images
  echo "Deploying the image"
  docker-compose up -d

  #Test the image has been deployed via http response
  echo "Test the HTTP port for a 403 response"
  starttime=$SECONDS
  while (($SECONDS < $starttime+90)) ; do
    HTTP_RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null localhost:8080)
    docker logs mb-jenkins 2>&1 | grep -qi 'Jenkins is fully up and running'
    if [[ $HTTP_RESPONSE == "403" &&  $? == 0 ]]; then
      echo "Jenkins is up and running"
      break
    else
      echo "Jenkins is not up and running: HTTP_RESPONSE=" $HTTP_RESPONSE
      sleep 10
    fi
  done

  #Test that the plugins installed correctly
  echo "Test the logs to see if all plugins have installed correctly"
  docker logs mb-jenkins 2>&1 | grep -qi 'Failed Loading plugin'
  if [[ $? == 0 ]]; then
    echo "Test failed, some plugins failing to load"
    echo "Displaying logs from the jenkins container"
    docker logs mb-jenkins
    exit 1
  else
    echo "Test passed"
  fi

  #Bring down the container
  echo "Stopping the container"
  docker-compose down
}

test
