# How to install CloudWatch Agent

* Source <https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/download-cloudwatch-agent-commandline.html>

## Windows

* Tested with Windows Server 2016.

1. Install Amazon CloudWatch Agent

    ~~~powershell
    Invoke-WebRequest -URI "https://amazoncloudwatch-agent.s3.amazonaws.com/windows/amd64/latest/amazon-cloudwatch-agent.msi" -OutFile "C:\01-install\amazon-cloudwatch-agent.msi"

    msiexec /i "C:\01-install\amazon-cloudwatch-agent.msi"
    ~~~

1. (Optional) run wizard if you don't have config.json file.

    ~~~powershell
    cd "C:\Program Files\Amazon\AmazonCloudWatchAgent"

    .\amazon-cloudwatch-agent-config-wizard.exe
    ~~~

    * This is basic (Disk and Mem) config for Windows

    ~~~json
    {
        "metrics": {
            "aggregation_dimensions": [
                [
                    "InstanceId"
                ]
            ],
            "append_dimensions": {
                "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
                "ImageId": "${aws:ImageId}",
                "InstanceId": "${aws:InstanceId}",
                "InstanceType": "${aws:InstanceType}"
            },
            "metrics_collected": {
                "LogicalDisk": {
                    "measurement": [
                        "% Free Space"
                    ],
                    "metrics_collection_interval": 60,
                    "resources": [
                        "*"
                    ]
                },
                "Memory": {
                    "measurement": [
                        "% Committed Bytes In Use"
                    ],
                    "metrics_collection_interval": 60
                },
                "statsd": {
                    "metrics_aggregation_interval": 60,
                    "metrics_collection_interval": 10,
                    "service_address": ":8125"
                }
            }
        }
    }
    ~~~

1. Attach policy "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" to the VM. [import_instance](import_instance.md) has instructions how to attach role with Terraform.
1. There are instructions below how to check status and start the CW Agent.

    ~~~powershell
    # Check status
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a status
    {
    "status": "stopped",
    "starttime": "",
    "configstatus": "not configured",
    "version": "1.300040.0b650"
    }

    # Start CloudWatch Agent
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c file:"C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json"

    # Check status
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a status
    {
    "status": "running",
    "starttime": "2024-06-04T10:42:52",
    "configstatus": "configured",
    "version": "1.300040.0b650"
    }

    # CloudWatch Agent is also shown in processes
    Get-Process -Name amazon*

    Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
    -------  ------    -----      -----     ------     --  -- -----------
        386      17    35548      55060       2.25   6756   0 amazon-cloudwatch-agent
        154      11    17820      16952     426.45   2992   0 amazon-ssm-agent
    ~~~

## Linux

### Debian

1. Install

    ~~~sh
    sudo apt-get update
    sudo apt-get upgrade -y
    cd /tmp/
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E amazon-cloudwatch-agent.deb
    sleep 5
    rm /tmp/amazon-cloudwatch-agent.deb

    # One can run wizard with command
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
    ~~~

1. Add config.json
1. Start, check status, enable service

    ~~~sh
    sudo systemctl start amazon-cloudwatch-agent.service
    sudo systemctl status amazon-cloudwatch-agent.service
    sudo systemctl enable amazon-cloudwatch-agent.service
    ~~~

1. Check logs

    ~~~sh
    tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
    ~~~

### Basic config.json

~~~sh
cat << EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/config.json
{
    "agent": {
            "metrics_collection_interval": 60,
            "run_as_user": "cwagent"
    },
    "metrics": {
            "aggregation_dimensions": [
                [
                    "InstanceId"
                ]
            ],
            "append_dimensions": {
                "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
                "ImageId": "${aws:ImageId}",
                "InstanceId": "${aws:InstanceId}",
                "InstanceType": "${aws:InstanceType}"
            },
            "metrics_collected": {
                "disk": {
                    "measurement": [
                            "used_percent"
                    ],
                    "metrics_collection_interval": 60,
                    "resources": [
                            "*"
                    ]
                },
                "mem": {
                    "measurement": [
                            "mem_used_percent"
                    ],
                    "metrics_collection_interval": 60
                },
                "statsd": {
                    "metrics_aggregation_interval": 60,
                    "metrics_collection_interval": 10,
                    "service_address": ":8125"
                }
            }
    }
}
EOF
~~~
