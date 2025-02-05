#!/bin/bash

# Can be run like:
# ./vaultwarden_backup.sh -c config.conf >> vw_backup.log

# Encryption process could be changed like in "security/gpg_encrypt_decrypt.md"

#####################################
##### SCRIPT INIT AND CHECKS
#####################################

datefile=$(date '+%Y%m%d-%H%M-%S')

#####################################
##### FUNCTIONS
#####################################

func_show_help () {
    cmd=$(basename "$0")
    echo "Usage: ${cmd} -c <configuration file>"
    echo " -h               Show this message"
    echo " -c               <Required> A configuration file."
}

func_upload () {

    if [[ "$transfer_method" == "aws" ]]
    then
		aws s3 cp --no-progress "$backup_root""$file_upload" "$s3_destination""$file_upload"
    elif [[ "$transfer_method" == "rsync" ]]
    then
        rsync -av -e "ssh -p $rsync_port" "$backup_root""$file_upload" "$rsync_user"@"$rsync_host":"$rsync_destination"
    fi
}

#####################################
##### SCRIPT MAIN
#####################################

# Parse options
# Colon : means that the option expects an argument.
while getopts "h?c:" opt; do
    case "$opt" in
    h|\?)
        func_show_help
        exit 0
        ;;
    c)  configfile=$OPTARG
    esac
done

shift "$((OPTIND-1))"
[[ "${1:-}" = "--" ]] && shift


### START Check required options
if [[ -z "${configfile}" ]]; then
    echo "ERROR: No configuration file was provided!"
    echo
    func_show_help
    exit 1;
fi
### END Check required options

source "$configfile"
echo "INFO: Configuration file content:"
cat "$configfile"

mkdir -p "$backup_dir"

# Copy data directory content
echo "Copying Vaultwarden data to backup dir"
rsync -av --progress "$vw_source" "$backup_dir"

# Create backup of sqlite database
echo "Creating backup of sqlite database"
docker run --rm \
    --volumes-from "$container_name" \
    -v "$vw_source":/data \
    sqlite3-deb sqlite3 /data/db.sqlite3 ".backup '/data/backups/vaultwarden_db_$datefile.sqlite3'"

# Move the db backup to backup directory
mv "$vw_source"/backups/vaultwarden_db_"$datefile".sqlite3 "$backup_dir"

# Copy docker compose file to backup directory
echo "Copying docker compose file to backup dir"
mkdir -p "$backup_dir"/docker_compose_files
rsync -av "$docker_compose_files"/* "$backup_dir"/docker_compose_files/

## Copy Docker file of the backup containter
#echo "Copying docker file to backup dir"
#mkdir -p "$backup_dir"/docker_file_for_backup
#rsync -av //* "$backup_dir"/docker_file_for_backup/

# Create tar file
echo "Creating backup tar ball"
tar_file="$backup_root""vaultwarden_backup_"$datefile".tar.gz"
tar -czf "$tar_file" -C "$backup_root" "vaultwarden_backup_$datefile"

# Encrypt
echo "Encrypting the tar ball"
gpg --output "$tar_file".gpg --encrypt --recipient "$recipient_encrypt" --trust-model always "$tar_file"

file_upload="vaultwarden_backup_$datefile.tar.gz.gpg"

# Copy into remote backup server
echo "Copying the encrypted tar ball to backup destination"
func_upload

# Remove the unencrypted backup files
rm -rf "$backup_dir"
rm -f "$tar_file"
