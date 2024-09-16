#!/bin/bash

# Can be run like:
# ./vaultwarden_backup.sh >> vw_backup.log

# Encryption process could be changed like in "security/gpg_encrypt_decrypt.md"

### VARIABLES
date_file=$(date '+%Y%m%d-%H%M')
backup_root="/backups/vaultwarden/"
backup_dir="$backup_root""vaultwarden_backup_$date_file/"
vw_source="/vw_data"
docker_compose_files="/docker_compose_files/vaultwarden/"
# Could Rsync, but the code needs to be changed in the end of this script.
#backup_dest="server:/destination/path/"
backup_dest="s3://BUCKET/vaultwarden/"
recipient_encrypt="email@address.com"

mkdir -p "$backup_dir"

# Copy data directory content
echo "Copying Vaultwarden data to backup dir"
rsync -av --progress "$vw_source" "$backup_dir"

# Create backup of sqlite database
echo "Creating backup of sqlite database"
docker run --rm \
    --volumes-from vaultwarden-vaultwarden-1 \
    -v "$vw_source":/data \
    sqlite3-deb sqlite3 /data/db.sqlite3 ".backup '/data/backups/vaultwarden_db_$date_file.sqlite3'"
# Move the db backup to backup directory
mv "$vw_source"/backups/vaultwarden_db_$date_file.sqlite3 "$backup_dir"

# Copy docker compose file to backup directory
echo "Copying docker compose file to backup dir"
mkdir -p "$backup_dir"/docker_compose_files
rsync -av "$docker_compose_files"/* "$backup_dir"/docker_compose_files/

# Copy Docker file of the backup containter
echo "Copying docker file to backup dir"
mkdir -p "$backup_dir"/docker_file_for_backup
rsync -av /docker_compose_files/vaultwarden_backup/* "$backup_dir"/docker_file_for_backup/

# Create tar file
echo "Creating backup tar ball"
tar_file="$backup_root""vaultwarden_backup_$date_file.tar.gz"
#tar -czf "$tar_file" -C "$backup_dir" "vaultwarden_backup_$date_file"
tar -czf "$tar_file" -C "$backup_root" "vaultwarden_backup_$date_file"

# Encrypt
echo "Encrypting the tar ball"
#encrypted_file="$tar_file".gpg
gpg --output "$tar_file".gpg --encrypt --recipient "$recipient_encrypt" --trust-model always "$tar_file"

file_upload="vaultwarden_backup_$date_file.tar.gz.gpg"

# Rsync into remote backup server
echo "Copying the encrypted tar ball to backup destination"
#rsync -av "$encrypted_file" "$backup_dest"
aws s3 cp --no-progress "$backup_root""$file_upload" "$backup_dest""$file_upload"

# Remove the unencrypted backup files
rm -rf "$backup_dir"
rm -f "$tar_file"
