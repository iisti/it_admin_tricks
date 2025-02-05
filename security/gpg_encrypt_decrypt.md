# Encrypt and decrypt files with GnuGP

## Create, import, export GPG key

~~~sh
sudo apt-get install gpg

gpg --gen-key
~~~

### Import public or private key

~~~sh
gpg --import public.key

gpg --list-keys
    gpg: checking the trustdb
    gpg: marginals needed: 3  completes needed: 1  trust model: pgp
    gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
    gpg: next trustdb check due at 2024-12-13
    /home/admin/.gnupg/pubring.kbx
    ------------------------------
    pub   rsa3072 2022-12-14 [SC] [expires: 2024-12-13]
          D80567DB13FE67B63822ECFBB27A56B3B848CFDE
    uid           [ultimate] Admin <example@example.com>
    sub   rsa3072 2022-12-14 [E] [expires: 2024-12-13]
~~~

### Export public key

The exported file content will start with `-----BEGIN PGP PUBLIC KEY BLOCK-----`

~~~sh
gpg --armor --output mypubkey.gpg --export <E-mail>
~~~

Or use username:

~~~sh
gpg --armor --output mypubkey.gpg --export "User Name"
~~~

### Export private key

The exported file content will start with `-----BEGIN PGP PRIVATE KEY BLOCK-----`

~~~sh
gpg --armor --output myprivate.gpg --export-secret-key "Admin"
~~~

### Encrypt a large file

Add & in the end of command if you want to follow progress

~~~sh
encrypt="filename"; gpg --output encrypted/"$encrypt".gpg --encrypt --recipient "email@example.com" "$encrypt" &
~~~

Progress can be followed with commands below.

* Source <https://unix.stackexchange.com/questions/288782/how-to-show-progress-with-gpg-for-large-files>

    ~~~sh
    gpg ... &
    progress -mp $!
    ~~~

## Create GPG encrypted TAR.GZ and upload to S3

* backup_list.txt

    ~~~sh
    /path/to/dir
    /path/to/file
    ~~~

* Script for creating GPG encrypted tar.gz and uploading it into S3

    ~~~sh
    #!/bin/bash
    
    if [ -z "$1" ]
    then
        echo "No list of files/folders to encrypt given."
        echo "Usage:"
        echo "./script.sh list.txt"
        exit 1
    fi

    ###############
    ### VARIABLES
    ###############
    
    backup_list="$1"
    gpg_pub_key="/home/admin/.gnupg/gpg_public.key"
    gpg_recipient="email@address.com"
    date_file="$(date +"%Y-%m-%d_%H-%M")"
    s3_destination="s3://BUCKET_NAME/backups/$date_file/"
    output_dir="/backups/"

    ###############
    ### FUNCTIONS
    ###############
    
    func_create_encrypted_tar_ball () {
        package="$1"
        output_name="$(echo "$package" | rev | cut -d'/' -f1 | rev)"
    
        # Create tar.gz
        tar -czvf "$output_name".tar.gz "$package"
    
        # Create temporary gpg keyring
        temp_keyring=/tmp/temporary_keyring_"$date_file".gpg
        gpg --no-default-keyring --primary-keyring "$temp_keyring" --import "$gpg_pub_key"
    
        # Encrypt
        gpg \
            --no-options \
            --no-default-keyring \
            --primary-keyring "$temp_keyring" \
            --encrypt \
            --cipher-algo AES256 \
            --always-trust \
            --no-random-seed-file \
            --recipient "$gpg_recipient" \
            --output "$output_dir""$output_name".tar.gz.gpg \
            "$output_name".tar.gz
    
        # Calculate sha256 sum
        sha256sum "$output_dir""$output_name".tar.gz.gpg > "$output_dir""$output_name".tar.gz.gpg.sha256sum
    
        # Remove temporary files
        rm "$output_name".tar.gz
        rm "$temp_keyring"
        rm "$temp_keyring"~
    }
    
    func_mv_to_s3 () {
    for file in "$output_dir"*.sha256sum; do { aws s3 mv "$file" "$s3_destination"; } done
    for file in "$output_dir"*.gpg; do { aws s3 mv "$file" "$s3_destination"; } done
    }
    
    func_print_arr () {
        # Reference the array correctly (not tmp_array="$1" )
        tmp_array=("$@")
    
        for (( i=0; i<${#tmp_array[@]}; i++ ))
        do
            echo "$i: ${tmp_array[$i]}"
        done
    }

    ###############
    ### MAIN
    ###############
    
    #func_print_arr "${arr_encrypt_these[@]}"
    
    while read i; do func_create_encrypted_tar_ball "$i"; done <<< "$(cat "$backup_list")"
    
    func_mv_to_s3
    ~~~

## Decrypt tar.gz.gpg

~~~sh
gpg_priv_key="/home/admin/.gnupg/gpg_private.key"
package="encypted_package"

# Create temporary gpg keyring
temp_keyring=temporary_keyring_$(date +"%Y-%m-%d_%H-%M").gpg
# Notice that this require inputting a passphrase if gpg-agent doesn't have it stored.
gpg --no-default-keyring --primary-keyring "./$temp_keyring" --import "$gpg_priv_key"

    # output should be similar to:
    gpg: keybox './temporary_keyring_2024-08-30_17-26.gpg' created
    gpg: key B27A56B3XXXXXXXX: public key "User Name <email@domain.com>" imported
    gpg: key B27A56B3XXXXXXXX: secret key imported
    gpg: Total number processed: 1
    gpg:               imported: 1
    gpg:       secret keys read: 1
    gpg:   secret keys imported: 1

# Decrypt
# Notice that this require inputting a passphrase if gpg-agent doesn't have it stored.
gpg \
    --no-options \
    --no-default-keyring \
    --primary-keyring "./$temp_keyring" \
    --decrypt \
    --default-recipient-self \
    --output "$package".tar.gz \
    "$package"

# Extract
tar -xvzf "<package>"
~~~
