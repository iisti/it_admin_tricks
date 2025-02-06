# IAM policy allow reboot/start/stop for some VMs

* One can make a group *restart-vm-group-01* and attach the policy below.
    * Change Account_ID
    ~~~
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "cloudwatch:DescribeAlarms",
                "Resource": "arn:aws:cloudwatch:*:{Account_ID}:alarm:*"
            },
            {
                "Sid": "VisualEditor1",
                "Effect": "Allow",
                "Action": [
                    "ec2:RebootInstances",
                    "ec2:StartInstances",
                    "ec2:StopInstances"
                ],
                "Resource": "arn:aws:ec2:*:*:instance/*",
                "Condition": {
                    "StringEquals": {
                        "ec2:ResourceTag/restart-vm-group-01": "true"
                    }
                }
            },
            {
                "Sid": "VisualEditor2",
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeImages",
                    "ec2:DescribeAddresses",
                    "ec2:DescribeInstances",
                    "compute-optimizer:GetEnrollmentStatus",
                    "ec2:GetConsoleScreenshot",
                    "ec2:DescribeInstanceStatus"
                ],
                "Resource": "*"
            }
        ]
    }
    ~~~
* The 1st part of the policy actions define that VMs with Tag key/value pair *restart-vm-group-01* / *true* can be started, stopped and restarted.
* Explanations of the 2nd part of the policy actions

    | Action | Explanation |
    |-|-
    | ec2:DescribeInstances | Allow showing details of instances
    | ec2:GetConsoleScreenshot | Allow showing troubleshooting image of the instance screen
    | ec2:DescribeImages | Get rid of error in section "AMI name" and "AMI location"
    | ec2:DescribeAddresses | Get rid of error in section "Elastic IP addresses"
    | ec2:DescribeInstanceStatus | Show instance status in instance list
    | cloudwatch:DescribeAlarms | Show alarms in instance list
    | compute-optimizer:GetEnrollmentStatus | Get rid of error in section "AWS Compute Optimizer finding"

## Instructions for employee

### How to reboot a VM in AWS

1. Go with browser to https://aws.amazon.com
   ~~~
   IAM user / Account ID (12 digits) or account alias: 123456789123
   IAM user name: firstname.lastname
   ~~~
1. In the web console, select from right up corner region: Europe Ireland (eu-west-1)
1. Go to service: EC2
1. Select from left menu: Instances
1. Select instance
    * Errors of retrieving/loading some information is normal as can have only partial permissions to see information.
1. Select from right up, Instance state -> Reboot
1. Instance state should be "Running"

### What's a VM doing?
* One can see a screenshot what the machine is doing, for example if restart seems to take long time one can check if the machine is doing Windows update by checking the screenshot.

1. Go with browser to https://aws.amazon.com
   ~~~
   IAM user / Account ID (12 digits) or account alias: 123456789123
   IAM user name: firstname.lastname
   ~~~
1. In the web console, select from right up corner region: Europe Ireland (eu-west-1)
1. Go to service: EC2
1. Select from left menu: Instances
1. Select instance
    * Errors of retrieving/loading some information is normal as can have only partial permissions to see information.
§. Select from right up, Actions -> Monitor and troubleshoot -> Get instance screenshot
    * If the screenshot shows "Press Ctrl+Alt+Delete to unlock.", one should be able RDP into it.
