# Encrypt and decrypt files with GnuGP

# Create GPG encrypted TAR.GZ and upload to S3

* backup_list.txt
    ~~~
    /path/to/dir
    /path/to/file
    ~~~

* Script for creating GPG encrypted tar.gz and uploading it into S3
    ~~~
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

# Decrypt tar.gz.gpg
~~~
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
