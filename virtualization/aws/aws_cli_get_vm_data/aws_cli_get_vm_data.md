# Scripts to retrieve VMs and their information from AWS

## Retrieve VMs from region
### Create CSV file
* This script retrieves VMs and selected data from region. A JSON and a CSV files are created.
    * [aws_cli_get_vm_data_csv.sh](aws_cli_get_vm_data_csv.sh)
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
