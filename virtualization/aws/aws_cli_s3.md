# How to copy files into S3 via AWS CLI

* Check AWS configuration, which shows default region
    
  ~~~
  aws configure list
          Name                    Value             Type    Location
          ----                    -----             ----    --------
       profile                <not set>             None    None
    access_key     ****************QEZA shared-credentials-file
    secret_key     ****************g+dy shared-credentials-file
        region                eu-west-1      config-file    ~/.aws/config
  ~~~

* List S3 buckets
  ~~~
  aws s3api list-buckets >> buckets.json
  ~~~
  
* Copy one file without recursion
  ~~~
  aws s3 cp test_upload.txt s3://vm-exports-01/
  ~~~

* Recursion
  ~~~
  aws s3 sync my_folder s3://vm-exports-01/my_folder
  ~~~
  * Or with *cp* and *--recursive*
  ~~~
  aws s3 cp my_folder s3://vm-exports-01/my_folder --recursive
  ~~~

* List files in bucket
  ~~~
  aws s3 ls s3://vm-exports-01
                             PRE vms/
  2021-03-09 13:26:35          4 test_upload.txt
  2021-03-02 20:10:17          0 vmimportexport_write_verification
  ~~~

* List objects and storage classes
  ~~~
  aws s3api list-objects --bucket vm-exports-01
  ~~~

* Extract descriptions (file names) of archived objects from Glacier JSON content
    * One needs to retrieve `glacier_inventory_content.json` before using this command.
        ~~~
        jq -r ".ArchiveList[] | .ArchiveDescription" glacier_inventory_content.json | jq '.path'
        ~~~
        
## How to backup into a AWS bucket with an IAM user
1. Create AWS bucket without public access, in this case bucket name is `backups-01`
3. Create IAM user for backups, in this case user name is `backup-01`
4. Create permission policy:
    * IAM -> Users -> `backup-01`-> Permissions -> Add inline policy
        * The permission could be make as a separate Customer managed policy and attached.   
    * This allows writing into the bucket, but not deleting. "s3:DeleteObject" action is required for delete permission.
    ~~~
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObjectAcl",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObjectAcl"
                ],
                "Resource": [
                    "arn:aws:s3:::backups-01",
                    "arn:aws:s3:::backups-01/*"
                ]
            }
        ]
    }
1. Configure AWS user
    ~~~
    aws configure
    ~~~
1. Create test file and upload
    * In PowerShell one can create a test file with command below.
    ~~~
    $text = "Hello World!" | Out-File -FilePath .\text.txt
    ~~~
    * Upload the file
    ~~~
    aws s3 cp .\text.txt s3://backups-01/
    ~~~
1. Start syncing real data
    * Example for syncing current folder in PowerShell
    ~~~
    aws s3 sync .\ s3://vm-backups-01/
    ~~~

* More instructions
  * https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
  * https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
