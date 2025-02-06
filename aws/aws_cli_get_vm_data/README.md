# Scripts to retrieve VMs and their information from AWS

## Retrieve VMs from region
### Create CSV file
* This script retrieves VMs and selected data from region. A JSON and a CSV files are created.
    * [aws_cli_get_vm_data_csv.sh](aws_cli_get_vm_data_csv.sh)
    * Change region by setting region in `config.conf`.
    * The CSV file will be something like below. IpOwnerId represents if the PublicIpAddress is Elastic IP or is the released when VM is shutdown/terminated.
        ~~~
        "Name (tag)","InstanceId","State","PrivateIpAddress","PublicIpAddress","IpOwnerId","InstanceType"
        "vm1","i-0d86f37c5asdfasdf","running","172.22.3.137","34.248.133.133","518711111111","t2.micro"
        "vm2","i-097dbb19dasdfasdf","running","10.23.0.98","34.233.175.33","amazon","t3a.xlarge"
        "vm2","i-06282d83e0416934a","stopped","172.22.23.75","-","-","c4.4xlarge"
        ~~~

### Create text table
* With this command one can create a text table of VM data. Piping | is used in the query and that could have been probably used in the CSV creation above also.
    ~~~
    aws ec2 describe-instances \
    --region eu-west-1 \
    --output table \
    --query  \
    'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], InstanceId: InstanceId,State: State.Name,PrivateIpAddress: PrivateIpAddress,PublicIpAddress: PublicIpAddress, IpOwnerId: NetworkInterfaces[].Association[].IpOwnerId | [0],InstanceType: InstanceType}'
    ~~~
    * Output
    ~~~
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    |                                                                  DescribeInstances                                                                 |
    +---------------------+---------------+---------------+-------------------------------------------+-------------------+------------------+-----------+
    |     InstanceId      | InstanceType  |   IpOwnerId   |                   Name                    | PrivateIpAddress  | PublicIpAddress  |   State   |
    +---------------------+---------------+---------------+-------------------------------------------+-------------------+------------------+-----------+
    |  i-03cdbfefdxxxxxxxx|  t3a.small    |  467111111111 |  vm1                                      |  10.21.0.116      |  54.180.129.131  |  running  |
    |  i-01f0b91d3xxxxxxxx|  t3a.large    |  None         |  vm2                                      |  10.21.0.74       |  None            |  stopped  |
    |  i-09f9d99d5xxxxxxxx|  t3a.xlarge   |  amazon       |  vm3                                      |  10.21.0.83       |  54.219.165.210  |  running  |
    +---------------------+---------------+---------------+-------------------------------------------+-------------------+------------------+-----------+
    ~~~

## Retrieve information of individual VM 
One can retrieve information of individual VM with the script `aws_get_instance_info.sh`.

## Check sum of volume usage

### Check sum of volume usage of one VM

* The commands below retrieve all volumes attached to VM and then prints sum of their sizes.

~~~sh
vm_id="i-0b048076e892dasdf"
aws --region eu-central-1 ec2 describe-volumes --filters Name="attachment.instance-id",Values="$vm_id" | jq -r '.Volumes[].Size' | awk '{sum+=$1} END {print sum}'
~~~

* Output should be something like

   ~~~sh
   195
   ~~~

### Check sum of volume usage of list of VMs

* Create aws_print_vm_volume_sum.sh
* Set the variables

~~~sh
#!/bin/bash

################
### VARIABLES
################

# Set region
region="eu-central-1"

# Create list of VMs
vms="i-0ca65f073cd141234
i-0b1bce7ff9283asdf"

##################
### SCRIPT
##################

# Create array
readarray -t arr_vms <<<"$vms"

# Print the VMs array, this is for checking that it's correct.
echo "Printing VM array"
declare -p arr_vms

# Function for printing instanceId and sum of the volume sizes
func_print_volume_sums () {
    # Reference the array correctly (not tmp_array="$1" )
    tmp_array=("$@")

    for (( i=0; i<${#tmp_array[@]}; i++ ))
    do
        vm_id=${tmp_array[$i]}

        volume_size_sum=$(aws --region "$region" ec2 describe-volumes \
            --filters Name="attachment.instance-id",Values="$vm_id" | \
            jq -r '.Volumes[].Size' | \
            awk '{sum+=$1} END {print sum}')

        echo "$vm_id $volume_size_sum"
    done
}

echo "Printing volume sums"
echo "InstanceId          Storage (GB)"
func_print_volume_sums "${arr_vms[@]}"
~~~

* Output should be something like

   ~~~sh
   Printing VM array
   declare -a arr_vms=([0]="i-0ca65f073cd141234" [1]="i-0b1bce7ff9283asdf")
   Printing volume sums
   InstanceId          Storage (GB)
   i-0ca65f073cd141234 51
   i-0b1bce7ff9283asdf 2325
   ~~~
