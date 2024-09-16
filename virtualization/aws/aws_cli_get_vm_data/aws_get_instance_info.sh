#!/bin/bash

# Script for retrieving information about an AWS instance.

echo "Testing access to AWS"
# Check that user has been authenticated. This is so that the user doesn't get
# blocked by spamming calls if the user is not authenticated properly.
result="$(aws iam get-user)" 2>&1

if [ ! "$?" -eq 0 ]
then
    echo ""
    echo "The user needs to be authenticated properly."
    exit 1
fi

output="./output/"

id="$1"
region="$2"
if [ ! "${#id}" -eq 19 ]
then
    echo "Instance ID should be in format i-12345678901234qwe"
    echo "Script usage:"
    echo "    ./aws_get_instance_info.sh i-12345678901234qwe eu-central-1"
    exit 1
elif [ -z "$region" ]
then
    echo "No region provided."
    echo "Script usage:"
    echo "    ./aws_get_instance_info.sh i-12345678901234qwe eu-central-1"
    exit 1
else
    echo "Retrieving instance description"
    description="$(aws ec2 describe-instances --region "$region" --instance-ids "$id")"
    echo "Extracting instance name from tags"
    vm_name="$(jq -r '.Reservations[].Instances[].Tags[] | select(.Key=="Name") | .Value' <<< "$description")"
    # Replace spaces in the VM name with underscores.
    vm_name=${vm_name// /_}
    # Add underscore to the VM name. If there's no Name tag, then no extra underscore is added to the output file name later.
    vm_name="${vm_name}_"

    echo "Output instance description into file"
    echo "$description" > "$output"aws_describe_instances_"$vm_name""$id".json
    security_group_ids="$(jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId' <<< "$description")"

    echo "Retrieve security groups and output into a file"
    while read sid; do aws ec2 describe-security-groups --region "$region" --no-paginate --group-ids "$sid"; done <<< "$(echo "$security_group_ids")" > "$output"aws_describe_instances_"$vm_name""$id"_security_groups.json

    echo "Retrieve volume information and output into a file"
    volume_ids="$(jq -r '.Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId' <<< "$description")"
    while read vid; do aws ec2 describe-volumes --region "$region" --no-paginate --volume-ids "$vid"; done <<< "$(echo "$volume_ids")" > "$output"aws_describe_instances_"$vm_name""$id"_volumes.json
fi
