# Export EC2 Volume to S3

* Tested on Linux
* Source https://docs.aws.amazon.com/cli/latest/reference/ec2/create-instance-export-task.html

1. Create Bucket and configure ACL
	
	~~~sh
	region="eu-central-1"
	bucket_name="vm-export-$region"
	# Check grantee id from https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport-prerequisites.html
	grantee_id="c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322"
	
	aws s3api create-bucket \
	--acl private \
	--object-ownership BucketOwnerPreferred \
	--region "$region" \
	--create-bucket-configuration LocationConstraint="$region" \
	--bucket "$bucket_name"
	
	aws s3api put-bucket-acl \
	--bucket "$bucket_name" \
	--grant-write id="$grantee_id" \
	--grant-read-acp id="$grantee_id"
	~~~

1. Export volume
   * Notice that only one volume at a time can be exported, so the VM needs to be shutdown and only one volume can be attached.
   * Remember to change the target environment and DiskImageFormat.
	
		~~~sh
		instance_id="i-00d4b3d301234qwer"
		prefix_vm="vm-name-data"
		
		aws ec2 create-instance-export-task \
		--region "$region" \
		--target-environment microsoft \
		--export-to-s3-task DiskImageFormat=VHD,S3Bucket="$bucket_name",S3Prefix="$prefix_vm" \
		--instance-id "$instance_id"
		~~~
 
1. Observe export task state

	~~~sh
 	aws ec2 --region $region describe-export-tasks --export-task-id export-i-0d0b67520asdfqwer
 	~~~~ 
