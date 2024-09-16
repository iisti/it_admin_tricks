# Terraform instructions

## How to install terraform

### WSL2 Debian 11 bullseye

* Linux Ubuntu/Debian commands need to be changed a bit, because Debian WSL doesn't have command `lsb_release -cs`

  ~~~sh
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(sed 's/VERSION_CODENAME=//;t;d' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ~~~

## GitHub

One can store Terraofrm state to AWS with AWS cli.

### Add github token to env variables

A token with admin rights is needed communicate with github.

Use token type `Tokens (classic)`. A `Fine-grained tokens` type didn't work even with all possible permissions.

`Tokens (classic)`, required scopes:
* repo (all)
* admin:org (all)
    * At least `read:org` is required.
* read:discussion, Read team discussions 
* admin:org_hook, Full control of organization hooks 

`export TF_VAR_github_token='<token>'`
 
`export TF_VAR_github_webhook_secret='<github_webhook>'`
