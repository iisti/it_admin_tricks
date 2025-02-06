#!/usr/bin/env bash

#####################################
##### SCRIPT INIT AND CHECKS
#####################################

# Retrieve from which folder the script is run
# Source: https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
func_get_script_source_dir () {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        # if $SOURCE was a relative symlink, we need to resolve it relative
        # to the path where the symlink file was located
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    local DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    echo $DIR
}

# Create directory for logging
mkdir -p "$(func_get_script_source_dir)"/logs

# Variable for adding date into file names
datefile=$(date +"%Y-%m-%d_%H-%M")
logfile="$(func_get_script_source_dir)"/logs/log_"$datefile".log

# Logging
# Example https://serverfault.com/a/103569/323362 
# Example 2: https://unix.stackexchange.com/a/67658/375094
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 2> >(tee -a "$logfile" >&2) \
    > >(tee -a "$logfile")

echo "$(date --iso-8601=seconds) #### Script started"

# Check that jq is installed
# redirects: 1st stderr to null and 2nd stdout to null, so nothing is printed on console
if ! jq --version 2> /dev/null | grep "jq-" 1> /dev/null
then
    echo "Package jq is required. Install the pacakge before running this script."
    exit 1
fi

#####################################
##### FUNCTIONS
#####################################

# Parsing configuration from config.conf
func_load_config () {

echo "Reading configuration from file."
# Example Configuration file
#
# # Account ID is (12 digits)
# account_id: 123456789012
# vaults: VaultName1

conf_file="$1"

# Remove spaces or tabs from beginning of lines.
# Reading file using cat.
conf_file=$(cat "$conf_file" | sed 's/^[ \t]*//g')

# Remove lines starting with # hashtag (remove comments)
# Reading variable using echo.
conf_file=$(echo "$conf_file" | sed '/^#/d')

# Remove all trailing spaces or tabs
conf_file=$(echo "$conf_file" | sed 's/[ \t]*$//')

# Remove all trailing commas. The arrays are created by separating items with comma.
conf_file=$(echo "$conf_file" | sed 's/,*$//')

# A variable to save any errors when parsing configuration file..
arr_error_conf=()

find_setting=("account_id" "region" "vault_name" "vault_archive_json" "vault_path" "remove_objects_file")

# Process Substition example:
# https://stackoverflow.com/a/19571082
while IFS= read -r line
do
    
    for setting in ${find_setting[@]}; do
    # Parse "setting", -n checks if string is longer than zero.
    if [ -n "$(echo $line | grep "^$setting")" ]
    then
        # Remove "setting: (and any space/tabs)" from the beginning of line
        #line=$(echo "$line" | sed 's/.*=[ \t]*//g')
        line=$(echo "$line" | sed "s/^$setting:[ \t]*//g")
        if [ -n "$line" ]
        then
            # eval is used for "expanding" the variable name
            eval "$setting"="$line"
        else
            # This is a bit stupid check as "setting" line needs to be still found
            # for this error to be registered. The setting is just empty.
            arr_error_conf+=("ERROR: No $setting found from config file!")
        fi
    fi
    done

done < <(echo "$conf_file")

# Check if there were fatal errors during parsing configuration file.
# If there were, print the errors and exit.
if (( ${#arr_error_conf[@]} )); then
    printf '%s\n' "${arr_error_conf[@]}"
    exit 1
fi

echo "### Loaded configuration"
echo "AWS Account ID:        $account_id"
echo "Vault name:            $vault_name"
echo "Vault archive JSON:    $vault_archive_json"
echo "Vault archive prefix:  $vault_path"
echo "Remove objects file:   $remove_objects_file"

}

func_rem_object () {
    object_name="$1"

    if [ "$object_name" = "metadata" ]
    then
        archive_id=$( \
            jq --arg DESCRIPT "{\"type\": \"$object_name\"}" \
                -r '.ArchiveList[] | select(.ArchiveDescription == $DESCRIPT)' "$vault_archive_json" | \
            jq -r '.ArchiveId')
    else
        archive_id=$( \
            jq --arg DESCRIPT "{\"path\": \"$vault_path$object_name\", \"type\": \"file\"}" \
                -r '.ArchiveList[] | select(.ArchiveDescription == $DESCRIPT)' "$vault_archive_json" | \
            jq -r '.ArchiveId')
    fi

    if [ -z "$archive_id" ]
    then
        echo "WARNING: Not found name, ID: $object_name $archive_id"
    else
        echo "Removing object name, ID: $object_name $archive_id"
        # The archive-id can start with minus - sign, so it needs to be wrapped
        # with quotes.
        aws glacier --region "$region" \
            delete-archive --vault-name "$vault_name" \
            --account-id $account_id \
            --archive-id \""$archive_id"\"
    fi
}

# Read to_be_removed_aws_objects.txt file into array.
# Loop through the array and use func_rem_object to remove the files.
func_read_file_and_rem () {
    readarray -t arr_rem_obj < "$remove_objects_file"

    for obj_name in "${arr_rem_obj[@]}"
    do
        func_rem_object "$obj_name"
    done
}

#####################################
##### DEFAULT VARIABLES
#####################################
#arr_vaults=()
account_id="empty"
region="empty"
vault_name="empty"
vault_archive_json="empty"
vault_path="empty"
remove_objects_file="empty"

# Script path
script_path=$(func_get_script_source_dir)

# Output path
mkdir -p "$script_path"/output
output_path="$script_path"/output/

# Configuration file
config_file="$script_path/config.conf"

#####################################
##### SCRIPT MAIN
#####################################

# Read vaults from conf file
func_load_config "$config_file"

# How to kill a sleeping script https://askubuntu.com/a/575708/484359
echo "# To kill the script process, issue the command below." > script.pid
echo "# This PID is checked with WSL, it might not work with Linux OS." >> script.pid
echo "pkill -P $PPID" >> script.pid

echo ""
cat script.pid
echo ""

echo ""
echo "### Removing objects/files from the vault"
func_read_file_and_rem

# Successful exit
exit 0
