# Jenkins instructions

## How to print secrets via Script Console

### Secret files

One can be printed with script below. Source: <https://stackoverflow.com/a/52209190/3498768>

Replace my-secret-file with your fileName.

~~~groovy
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.Domain;
import org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl;

println "Jenkins credentials config file location=" + SystemCredentialsProvider.getConfigFile();
println ""

def fileName = "my-secret-file"

SystemCredentialsProvider.getInstance().getCredentials().stream().
  filter { cred -> cred instanceof FileCredentialsImpl }.
  map { fileCred -> (FileCredentialsImpl) fileCred }.
  filter { fileCred -> fileName.equals( fileCred.getFileName() ) }.
  forEach { fileCred -> 
    String s = new String( fileCred.getSecretBytes().getPlainData() )
    println "XXXXXX BEGIN a secret file with fileName=" + fileName + " XXXXXXXXXXXX"
    println s
    println "XXXXXX END a secret file with fileName=" + fileName + " XXXXXXXXXXXX"
    println ""
  }
~~~

### Secrets except files

Source: <https://gist.github.com/timja/04afb12c8ad909e400317a2ad9c88445>

~~~groovy 
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import org.jenkinsci.plugins.plaincredentials.impl.*

  
// def item = Jenkins.instance.getItem("your-folder")

def creds = CredentialsProvider.lookupCredentials(
        com.cloudbees.plugins.credentials.Credentials.class,
        Jenkins.instance, // replace with item to get folder or item scoped credentials 
        null,
        null
);

for (credential in creds) {
  if (credential instanceof UsernamePasswordCredentialsImpl) {
    println credential.getId() + " " + credential.getUsername() + " " + credential.getPassword().getPlainText()
  } else if (credential instanceof StringCredentialsImpl) {
    println credential.getId() + " " + credential.getSecret().getPlainText() 
  } else if(credential instanceof BasicSSHUserPrivateKey) {
    println credential.getId() + " " + credential.getUsername() + "\n" + credential.getPrivateKey() + "\n Passphrase: " + credential.getPassphrase()
  } else if (credential.getClass().toString() == "class com.microsoft.azure.util.AzureCredentials") {
    println "AzureCred:" + credential.getSubscriptionId() + " " + credential.getClientId() + " " + credential.getPlainClientSecret() + " " + credential.getTenant()
  } else if (credential.getClass().toString() == "class org.jenkinsci.plugins.github_branch_source.GitHubAppCredentials") {
    println credential.getId() + " " + credential.getUsername() + "\n" + credential.getPrivateKey().getPlainText()
  } else if (credential.getClass().toString() == "class com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl") {
    println credential.getId() + " " + credential.getAccessKey() + " " + credential.getSecretKey()
  } else if (credential.getClass().toString() == "class com.microsoft.jenkins.keyvault.SecretStringCredentials"
            || credential.getClass().toString() == "class org.jenkinsci.plugins.azurekeyvaultplugin.credentials.string.AzureSecretStringCredentials") {
  } else {
    println credential.getClass()
  } 
}
~~~

### Cleanup folders left behind by wsCleanup

Jenkins leaves sometimes folders behind with syntax `JOBNAME_ws-cleanup_TIMESTAMP` if Workspace Cleanup <https://plugins.jenkins.io/ws-cleanup/> plugin is used.

One can create a cronjob to remove those folders. The command below removes the folders.

~~~
cd /var/lib/jenkins/workspace/ \
  && sudo find . -type d -name "*_ws-cleanup_*" -exec rm {} \;
~~~
