#!/bin/bash

# Import configuration file
source config.conf

#################
### VARIABLES
#################
output="./output/"

#################
### SCRIPT MAIN
#################

# If AWS profile has not been set, don't set profile_cmd.
# aws cli didn't accept using just one variable like profile="--profile prof1",
# so the parameter needed to be split in 2 variables.
if [[ -z "$profile" ]]
then
    echo "Warning: No profile is set, so you should have default AWS profile configured."
    profile_cmd=""
else
    profile_cmd="--profile"
fi

aws_instances="$output""aws_instances_$(date +"%Y-%m-%d_%H-%M")"; \
aws "$profile_cmd" "$profile" \
    ec2 describe-instances \
    --region "$region" \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value,InstanceId,State.Name,PrivateIpAddress,PublicIpAddress,NetworkInterfaces[].Association[].IpOwnerId,InstanceType]' \
    --output json \
    > "$aws_instances".json && \
jq -r '[.[][] | if . == null or . == [] then "-" else . end | .[]? // . ] | @csv' "$aws_instances".json > "$aws_instances".csv && \
sed -i "s/,/\n/7; P; D" "$aws_instances".csv && \
sed -i '1s/^/"Name (tag)","InstanceId","State","PrivateIpAddress","PublicIpAddress","IpOwnerId","InstanceType"\n/' "$aws_instances".csv


# Explanations of the script lines
# aws_instances                                       == file name variable
# aws ec2 describe-instances ...                      == actual query which creates a JSON file of the data
# jq -r ...                                           == creates a one line CSV file of the JSON file
#     | if . == null or . == [] then "-" else . end   == if empty array or null, then replace with -
#     | .[]? // .                                     == removes the array brackets, so only Tag "Name" is printed
# sed 1st line                                        == adds newlines between different VM data
# sed 2nd line                                        == add header to the CSV file

# The CSV file will be something like below. IpOwnerId represents if the PublicIpAddress is Elastic IP or is the released when VM is shutdown/terminated.
# "Name (tag)","InstanceId","State","PrivateIpAddress","PublicIpAddress","IpOwnerId","InstanceType"
# "vm1","i-0d86f37c5asdfasdf","running","172.22.3.137","34.248.133.133","518711111111","t2.micro"
# "vm2","i-097dbb19dasdfasdf","running","10.23.0.98","34.233.175.33","amazon","t3a.xlarge"
# "vm2","i-06282d83e0416934a","stopped","172.22.23.75","-","-","c4.4xlarge"
