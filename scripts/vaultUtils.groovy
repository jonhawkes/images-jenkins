import groovy.json.JsonSlurper
def version='1.0'

def getDefaultVaultURL(){
  return "http://vault:8200";
}

def getDefaultCredentialId(){
  return "github-oauth-token";
}

def login() {
  return login(getDefaultVaultURL(), getDefaultCredentialId())
}

def login(vaultURL, credId) {
  def result;

  withCredentials([[$class:'StringBinding', credentialsId:credId, variable: 'OAUTH_TOKEN']]) {
    def curl = "curl -X POST $vaultURL/v1/auth/github/login -d '{\"token\":\"$OAUTH_TOKEN\"}'"
    result = sh ( script: curl, returnStdout: true ).trim()
  }

  def jsonSlurper = new JsonSlurper();
  def object = jsonSlurper.parseText(result);
  def client_token = object["auth"]["client_token"]

  return client_token;
}

def putValue(path, key, value){
  def clientToken = login()
  putValue(clientToken, getDefaultVaultURL(), path, key, value);
}

def putValue(clientToken, vaultURL, path, key, value){
  def curl = "curl -H \"X-Vault-Token:$clientToken\" -X PUT $vaultURL/v1/secret/$path/$key -d '{\"value\":\"$value\"}'"
  def result = sh ( script: curl, returnStdout: true ).trim()
}

def getProperties(path){
  def clientToken = login()
  return getProperties(clientToken, getDefaultVaultURL(), path);
}

def getProperties(clientToken, vaultURL, path){
  if(!path.endsWith("/")){
    path = path + "/"
  }
  return getProperties(clientToken, vaultURL, path, null);
}

def getProperties(clientToken, vaultURL, path, prefix){
  def props = [:];

  def keys = getKeys(clientToken, vaultURL, path);
  for(String key: keys){

    def valuePath = path+key;
    if(key.endsWith("/")){

      def keyLength = key.length();
      def subPrefix = key.substring(0,keyLength-1);
      if(prefix != null){
        subPrefix = prefix + "_" + subPrefix
      }

      def subProps = getProperties(clientToken, vaultURL, valuePath, subPrefix);
      for(String subKey:subProps.keySet()){
        def subValue = subProps.get(subKey);
        props.put(subKey, subValue)
      }
    }
    else{
      def value = getValue(clientToken, vaultURL, path+key)
      def propName = key;
      if(prefix != null){
        propName = prefix + "_" + key
      }

      props.put(propName, value);
    }
  }
  return props;
}

def getKeys(clientToken, vaultURL, path){
  def curl = "curl -H \"X-Vault-Token:$clientToken\" -X GET $vaultURL/v1/secret/$path?list=true"
  def result = sh ( script: curl, returnStdout: true ).trim()
  println(result);
  
  def jsonSlurper = new JsonSlurper();
  def object = jsonSlurper.parseText(result);
  def data = object.data;
  def keys = null;
  if(data != null){
    if(data.keys != null && data.keys.size() > 0){
      keys = data.keys;
    }
  }
  println(keys);
  return keys;
}

def getValue(clientToken, vaultURL, path){
  def curl = "curl -H \"X-Vault-Token:$clientToken\" -X GET $vaultURL/v1/secret/$path"
  def result = sh ( script: curl, returnStdout: true ).trim()

  def jsonSlurper = new JsonSlurper();
  def object = jsonSlurper.parseText(result);
  def data = object.data;
  def value = null;
  if(data != null){
    value = data.value;
  }
  return value;
}

return this;
