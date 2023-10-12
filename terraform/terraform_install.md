# How to install terraform

## WSL2 Debian 11 bullseye
* Linux Ubuntu/Debian commands need to be changed a bit, because Debian WSL doesn't have command `lsb_release -cs`
  ~~~
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(sed 's/VERSION_CODENAME=//;t;d' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ~~~
