# Terraform Artifactory
Repository for configuring Artifactory with Terraform.

## Prequisites

*  Install Terraform
    * https://developer.hashicorp.com/terraform/downloads
* One has to have Artifactory admin permissions.
### Create Artifactory access token
1. Login into https://artifactory.domain.example
1. Click your user on the right up corner
1. Click Edit Profile
1. Click Generate an Identity Token
1. Save the access/identity token
### Add the Artifactory access token into environment variables
#### Linux
One can automate the exporting the environment variable like this.

1. Create ~/.tf_artifactory_token file with content below. Of course one needs to replace the `<artifactory_access_token>` with an actual token.
    ~~~
    TF_VAR_artifactory_access_token="<artifactory_access_token>"
    ~~~
1. Add these lines into end of ~/.bashrc file
    ~~~
    # For managing Artifactory with Terraform
    source ~/.tf_artifactory_token
    export TF_VAR_artifactory_access_token
    ~~~
1. Now when a new shell is opened the access token will be exported automatically and Terraform can be used with Artifactory.

# Terraform configurations
The Terraform configurations have been split to different subdirectories, so that applying the configurations don't take much time.

## Subdirectories:
* repos = for creation repositories
* permissions = for creating permissions
* users = for creating users
  * this hasn't been actually created yet, maybe this could be combined with groups?
* groups = for creating groups
  * this hasn't been actually created yet, maybe this could be combined with users?
