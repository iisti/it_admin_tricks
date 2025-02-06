# Check private IP of an RDS instance

1. Go to RDS Console.
1. Select Databases and find required DB Instance. Open it and find details.
1. Go to **Connectivity & security** and find **VPC security groups**.
    * sg-yyyyyyyyyxxxxxxxx
1. Go to EC2 Console
1. Select **NETWORK & SECURITY** → **Network Interfaces**.
1. Filter by Security Group or just find an interface by Security group from 3rd point.
1. Select found interface and look at Primary private IPv4 IP. This is the internal ip-address which you require.
1. There can be multiple IPs, so when checking with `nslookup rdsdb01.cluster-xxxxxxxxxxxx.eu-central-1.rds.amazonaws.com` it gives x.y.z.w.
    * x.y.z.w → 10.x.y.z
