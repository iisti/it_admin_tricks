# Mount S3 bucket with s3fs

* Tested with Debian 10 and Amazon Linux 2

# s3fs recommendations
* Option recommendations
   * Source https://www.ispcolohost.com/2013/10/23/s3fs-rsync-recommendations/
   ~~~
   rsync -avW --progress --inplace --size-only <source> <destination>
   ~~~
   * Options
      ~~~
      -a:
          Recurse directories
          Include symlinks
          Include permissions
          Include modification times
          Include group (although in most cases this is meaningless since most users of S3FS use the hard-coded uid, gid and allow_other arguments to ensure the filesystem works correctly for the intended user)
          Include owner (similarly meaningless)
          Include devices (not sure if device objects can be represented in S3FS, haven’t tried it)
      
      -v: verbose
      
      -W: copy whole files.  This prevents rsync from trying to do checksums and only replace pieces of the destination file because in the S3FS world, the entire file is going to come down, be modified, and pushed back up, which is much worse than simply pushing the new version of the file up and not trying to modify parts of it.  rsync doesn’t realize the filesystem is remote.
      
      –progress: useful to watch what it’s doing since rsync’ing files over S3FS is sloooooow.  This will also tell you if it has hung and give you speed stats.
      
      –size-only: copy based on the file’s size, not the date, time or checksum.  I’ve found the date/time is often not very useful, especially if using the filesystem from multiple systems.
      
      –inplace: copy changed blocks directly into the destination file; can save you considerably on S3 inbound/outbound bandwidth if you have small changes to large files.  (Credit to commenter for suggesting this)
      ~~~ 

# Install and configure
1. Install s3fs
    * Debian 10 
        ~~~
        sudo apt update
        sudo apt install s3fs
        ~~~
    * Amazon Linux 2
        * Source https://github.com/s3fs-fuse/s3fs-fuse/wiki/Installation-Notes#amazon-linux
        ~~~
        sudo sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/epel.repo
        sudo yum install -y gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel libxml2-devel mailcap automake openssl-devel git
        git clone https://github.com/s3fs-fuse/s3fs-fuse
        cd s3fs-fuse/
        ./autogen.sh
        ./configure --prefix=/usr --with-openssl
        make
        sudo make install
        ~~~
1. Configure IAM Policy
   * In this policy only subkey / subdir is allowed to write into.
    ~~~
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject",
                    "s3:DeleteObject",
                    "s3:ListObject",
                    "s3:PutObject"
                ],
                "Resource": [
                    "arn:aws:s3:::bucket007/path/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::bucket007"
                ]
            }
        ]
    }
    ~~~
1. Create s3-mount-role007 and attach policy the policy.
1. Change the EC2 Instance's IAM role.
1. Create mount point
    ~~~
    mkdir /mnt/bucket007
    ~~~
1. Mount via shell
    ~~~
      s3fs -o iam_role="s3-mount-role007" -o url="https://s3-eu-north-1.amazonaws.com" -o dbglevel=info -o curldbg -o allow_other -o uid=1000,gid=1000,mp_umask=002 bucket007 /mnt/bucket007 
    ~~~
    * Options, more info at https://github.com/s3fs-fuse/s3fs-fuse/wiki/Fuse-Over-Amazon#options
      * `dbglevel=info`     = debugging
      * `curldbg`           = debugging
      * `allow_other`       = without this the user permissions mess up and only root can use the mount
      * `uid=1000,gid=1000` = Owner user and group IDs
      * `mp_umask=002`      = Remove write "other" access from bucket root
      * `umask=007`         = Remove all "other" access from objects in the bucket
      * `use_cache=/tmp`    = This is not used, but it's in many examples. It would mean that there will be local copies of files. More information at https://github.com/s3fs-fuse/s3fs-fuse/wiki/Fuse-Over-Amazon#details
1. Or mount via `/etc/fstab`.
   ~~~
   # s3fs
   bucket007 /mnt/bucket007 fuse.s3fs _netdev,allow_other,iam_role=s3-mount-role007,uid=1000,gid=1000,mp_umask=007,umask=007 0 0
   ~~~
   * Options
     * 0 = no dumping of filesystem
     * 2 = non-root device

