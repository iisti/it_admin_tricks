# How to import AWS instance into Terraform

This VM has IAM Role and attached policies for SSM, CloudWatch Agent, and backup bucket.

1. Create main.tf use [import_instance.tf](import_instance.tf) as a template
1. Leave the resource "aws_instance" "vm" empty.
1. `terraform import aws_instance.vm i-1234567890qwertyu`
1. `terraform state list`
1. Use `terraform state show aws_instance.vm` and copy the state into main.tf.
1. Check with `terraform plan` and remove lines that are conflicting.
1. Configure local variables and add tags parameter, so that configuration is easy to change.

    ~~~tf
    # tags was added after Terraform import
    tags = merge(
        local.tags_vm, local.tags_for_all
    )
    ~~~

1. (Optional) Enable IAM Role.
