# Restore a Windows VM from a snapshot

## The basic concept of the script
1. Shutdown VM.
1. Detach messed up volume.
1. Create volume from a working snapshot and attach it.
1. Power up the VM.

## Running the script
1. The script is requires AWS CLI, so that it can be run.
    * The script has been tested only with AWS CLI 2.x
1. Create a profile in ~/.aws/config
    ~~~
    [profile profile_name]
    region = eu-west-1
    output = json
    ~~~
1. Add credentials into ~/.aws/credentials
    ~~~
    [profile_name]
    aws_access_key_id = ACCESSKEYID
    aws_secret_access_key = SECRETACCESSKEY
    ~~~
1. Create configuration file from **config_exmpale.conf** to run with your setup.
1. Run the script with command
    ~~~
    ./aws_restore_win_vm_from_snapshot.sh config_vm007.conf
    ~~~

## Create IAM policy for more security
* One can restrict the permissions of the user which is running this script via
  IAM policy.
1. Create AWS IAM user and save the AWS CLI credentials.
1. Create policy with the example file iam_policy_example.json
    * One can restrict the policy more by adding AWS Account ID into the arn, e.g.
        "arn:aws:ec2:\*:123456789012:instance/\*"
    * Another way is to restirct the run only from certain IPs with the "Condition" rule.
1. Create AWS CLI profile and run the script.
