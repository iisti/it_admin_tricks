# Cloud-init instructions

## How to write multiline file with Terraform and cloud-init

### An example how variable interpolation messed up YAML syntax.

Normal YAML cloud-init userdata file will interpolate variable with multiline string content with bad indentation. See user_data.yaml example below.

* test_script variable content

  ~~~sh
  #!/bin/bash

  echo "test" > /tmp/test_var.txt
  ~~~

* user_data.yaml

    ~~~yaml
    #cloud-config
    write_files:
      - path: /tmp/test_script.sh
        permissions: '0744'
        content: ${local.test_script}
    ~~~~

* Interpolated content of user_data.yaml. One can see that line `echo "test" > /tmp/test_var.txt` indent has disappeared, which messes up YAML syntax.

    ~~~sh
    - path: /tmp/test_script.sh
      permissions: '0744'
      content: |
        #!/bin/bash

    echo "test" > /tmp/test_var.txt
    ~~~

### How to address the interpolation issue

1. Create userdata.tftpl

    ~~~sh
    #cloud-config
    ${yamlencode({
    write_files = [
      {
        path = "/tmp/test_script.sh"
        permissions = "0744"
        content = test_script
      },
    ]
    })}
    ~~~

1. The userdata is rendered in locals block.
    
    ~~~sh
    locals {
      # test_script could also have variable interpolation: test_script = templatefile("test_script.sh", {...
      test_script = file("test_script.sh")

      userdata = templatefile("userdata.tftpl", {
        test_script = local.test_script
      })
    }
    ~~~

1. Set user_data in vm resource. hcloud = Hetzner

    ~~~sh
    resource "hcloud_server" "vm" {
      user_data = local.userdata
    }
    ~~~

1. One could check output of `local.userdata`

    ~~~sh
    output "userdata" {
      value = local.userdata
    }
    ~~~
