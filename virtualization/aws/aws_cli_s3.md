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
  aws s3 sync folder s3://vm-exports-01/folder
  ~~~
  * Or with *cp* and *--recursive*
  ~~~
  aws s3 cp folder s3://vm-exports-01/folder --recursive
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
  
* More instructions
  * https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
  * https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
