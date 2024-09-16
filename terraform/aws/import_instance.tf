terraform {
  required_version = ">= 1.5.5"
  backend "s3" {
    bucket = "tfstates"
    key    = "aws-vm01-prod"
    region = "eu-central-1"
  }
}

locals {
  base_name             = "aws"
  vm_name               = "vm01" // Don't use dash "-" in the name. It breaks at least Sid element in IAM policies.
  env                   = "prod"
  naming_prefix         = "${local.base_name}-${local.vm_name}-${local.env}"
  aws_region            = "eu-west-1"

  iam_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  # Tags
  terraform             = "imported"
  owner                 = "example@email.com"
  backup_policy         = "prod-weekly-tuesday"
  restart_vm_developer  = "false"
  purpose               = "A VM for hosting application"
  backup_bucket         = "backup-01"
  cost_tag              = "hosting"

  tags_vm = {
    purpose               = local.purpose
    Name                  = local.naming_prefix
    backup-policy         = local.backup_policy
    restart-vm-developer  = local.restart_vm_developer
  }

  tags_for_all = {
    terraform             = local.terraform
    owner                 = local.owner
    cost-tag              = local.cost_tag
  }
}

provider "aws" {
  region = local.aws_region
}

# Leave this empty before the import.
resource "aws_instance" "vm" {

}

/*
#### START IAM ROLE
resource "aws_iam_role" "vm_role" {
  name  = "${local.naming_prefix}-iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    { Name = "${local.naming_prefix}-iam" }, local.tags_for_all
  )
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  for_each = local.iam_policies

  role       = aws_iam_role.vm_role.name
  policy_arn = "${each.value}"
}

resource "aws_iam_role_policy" "vm_ec2" {
  name  = "${local.naming_prefix}-iam-ec2"
  role  = aws_iam_role.vm_role.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${local.vm_name}Ec2Iam",
            "Action": [
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "${local.vm_name}Ec2S3Operations",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${local.backup_bucket}/${local.naming_prefix}/*"
            ]
        },
        {
            "Sid": "${local.vm_name}Ec2S3List",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.backup_bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "vm_role" {
  name  = "${local.naming_prefix}-iam"
  role  = aws_iam_role.vm_role.name
}
#### END IAM ROLE
*/