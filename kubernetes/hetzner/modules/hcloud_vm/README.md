# VM module for Hetzner Cloud Hcloud

## Installation

1. Set .tfvars in root module to something like:

    ~~~sh
    hcloud_token = "qwer1234" # cicd
    ssh_key_pub_admin = "ssh-ed25519 qwer1234 email@example.com"
    ~~~

1. It takes a while that the VM installs and configures itself with cloud-init. One can SSH into the VM and check logs.

    ~~~sh
    sudo less +F /var/log/cloud-init-output.log
    ~~~
