# jq tricks

## How to extract data with jq and loop requests with Bash

Tested with `aws-cli/2.4.21 Python/3.8.8 Linux/5.15.90.1-microsoft-standard-WSL2 exe/x86_64.debian.11 prompt/off`

### Remove multiple directories from AWS S3 bucket

We want to remove multiple directories from AWS S3 backup bucket. There are hundreds of backups, so we don't want to do it manually. In the example there are only couple directories/prefixes to simplify the example.

The syntax of the path is as below. The date changes, so we need to retrieve the dates and use that as index when looping to remove the directories.

`s3://bucket_name/prefix_name/backup_2023-09-15T0200/path/obsolete_dir`

1. Let's retrieve objects from S3 bucket with AWS CLI.

    ~~~shell
    aws --output json s3api list-objects --bucket <bucket_name> --prefix '<prefix_name>/' --delimiter '/'
    ~~~

    * Output

        ~~~json
        {
            "CommonPrefixes": [
                {
                    "Prefix": "prefix_name/backup_2023-10-13T0200/"
                },
                {
                    "Prefix": "prefix_name/backup_2023-10-20T0200/"
                },
                {
                    "Prefix": "prefix_name/config/"
                },
                {
                    "Prefix": "prefix_name/latest/"
                },
                {
                    "Prefix": "prefix_name/wp_backup_2023-05-26T0300/"
                },
                {
                    "Prefix": "prefix_name/wp_backup_2023-05-27T0300/"
                },
                {
                    "Prefix": "prefix_name/wp_backup_2023-05-28T0300/"
                },
                {
                    "Prefix": "prefix_name/wp_latest/"
                }
            ]
        }
        ~~~

1. Now let's use jq to filter only the directories/prefix that we want.

    ~~~shell
    aws --output json s3api list-objects --bucket <bucket_name> --prefix '<prefix_name>/' --delimiter '/' | jq -r '.CommonPrefixes[] | select(.Prefix | startswith("prefix_name/backup")).Prefix'
    ~~~

    * Output

      ~~~shell
      prod/backup_2023-10-13T0200/
      prod/backup_2023-10-20T0200/
      ~~~

1. Let's test with Bash that we can use the output in a loop.

    ~~~shell
    while read prefix; do echo "prefix:$prefix"; done <<< "$(aws --output json s3api list-objects --bucket jenkins --prefix 'prod/' --delimiter '/' | jq -r '.CommonPrefixes[] | select(.Prefix | startswith("prod/backup"))'.Prefix)"
    ~~~

    * Output

      ~~~shell
      prefix:prod/backup_2023-10-13T0200/
      prefix:prod/backup_2023-10-20T0200/
      ~~~

1. Now let's remove the objects

    ~~~shell
    while read prefix; do aws s3 rm --recursive s3://bucket_name/"$prefix"path/obsolete_dir; done <<< "$(aws --output json s3api list-objects --bucket jenkins --prefix 'prod/' --delimiter '/' | jq -r '.CommonPrefixes[] | select(.Prefix | startswith("prod/backup"))'.Prefix)"
    ~~~

### Restore versioned files in S3 bucket (remove delete markers)

* This script is inefficient, but it was left here as an example usage of jq.
* Use script [aws_rem_versioned_objs.sh](../virtualization/aws/aws_rem_versioned_objs/aws_rem_versioned_objs.sh) to remove files and/or delete markers.

1. Get delete markers

   ~~~shell
   bucket_name="backup007"
   prefix="prefix/path/"
   datefile=$(date +"%Y-%m-%d_%H-%M")
   keys_to_delete_json="key_value_""$datefile"".json"
   aws s3api list-object-versions --bucket "$bucket_name" --prefix "$prefix" --query 'DeleteMarkers[?IsLatest==`true`]' > "$keys_to_delete_json"
   ~~~

   * The output JSON is something like this:

      ~~~json
      [
          {
              "Owner": {
                  "ID": "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
              },
              "Key": "prefix/path/2024-02-09_01-50/asdf.tar",
              "VersionId": "T5RF7Ox7FV7drmtHct1QNuRblxxxxxxx",
              "IsLatest": true,
              "LastModified": "2024-02-16T16:34:30+00:00"
          },
          {
              "Owner": {
                  "ID": "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
              },
              "Key": "prefix/path/2024-02-09_01-50/qwer.tar",
              "VersionId": "ap7HDBRRvPSGmHomIVnUCh6kvdxxxxxx",
              "IsLatest": true,
              "LastModified": "2024-02-16T16:34:30+00:00"
          }
      ]
      ~~~

1. Print delete markers

   ~~~shell
   jq -r 'map(select(.[]) | .Key + "|" + .VersionId) | .[]' < "$keys_to_delete_json" |\
       uniq |\
       while IFS='|' read key value; do echo "$key $value"; done
   ~~~

1. Remove the delete markers

   ~~~shell
   jq -r 'map(select(.[]) | .Key + "|" + .VersionId) | .[]' < "$keys_to_delete_json" |\
    uniq | \
    while IFS='|' read key value ;\
    do aws s3api delete-object --bucket "$bucket_name" --key "$key" --version-id "$value" ;\
    done
   ~~~

## Extract local IP of Linux machine

* Extract local IP of Linux VM with command below

    ~~~shell
    ip --json a s | jq -r '.[].addr_info[0] | select(.label | startswith("eth")).local'
    ~~~

    * Output
        
        ~~~shell
        172.23.181.224
        ~~~

* Whole output with command `ip --json a s | jq`

    ~~~json
    [
      {
        "ifindex": 1,
        "ifname": "lo",
        "flags": [
          "LOOPBACK",
          "UP",
          "LOWER_UP"
        ],
        "mtu": 65536,
        "qdisc": "noqueue",
        "operstate": "UNKNOWN",
        "group": "default",
        "txqlen": 1000,
        "link_type": "loopback",
        "address": "00:00:00:00:00:00",
        "broadcast": "00:00:00:00:00:00",
        "addr_info": [
          {
            "family": "inet",
            "local": "127.0.0.1",
            "prefixlen": 8,
            "scope": "host",
            "label": "lo",
            "valid_life_time": 4294967295,
            "preferred_life_time": 4294967295
          },
          {
            "family": "inet6",
            "local": "::1",
            "prefixlen": 128,
            "scope": "host",
            "valid_life_time": 4294967295,
            "preferred_life_time": 4294967295
          }
        ]
      },
      {
        "ifindex": 2,
        "ifname": "eth0",
        "flags": [
          "BROADCAST",
          "MULTICAST",
          "UP",
          "LOWER_UP"
        ],
        "mtu": 1500,
        "qdisc": "mq",
        "operstate": "UP",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "00:15:5d:03:fb:1b",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "addr_info": [
          {
            "family": "inet",
            "local": "172.23.181.224",
            "prefixlen": 20,
            "broadcast": "172.23.191.255",
            "scope": "global",
            "label": "eth0",
            "valid_life_time": 4294967295,
            "preferred_life_time": 4294967295
          },
          {
            "family": "inet6",
            "local": "fe80::215:5dff:fe03:fb1b",
            "prefixlen": 64,
            "scope": "link",
            "valid_life_time": 4294967295,
            "preferred_life_time": 4294967295
          }
        ]
      }
    ]
    ~~~
