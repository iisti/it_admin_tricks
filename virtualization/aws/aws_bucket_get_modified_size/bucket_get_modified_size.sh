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

echo "$(date --iso-8601=seconds) #### Script started #### "

# Check that jq is installed
# redirects: 1st stderr to null and 2nd stdout to null, so nothing is printed on console
if ! jq --version 2> /dev/null | grep "jq-" 1> /dev/null
then
    echo "Package jq is required. Install the pacakge before running this script."
    exit 1
fi

# Parsing configuration from config.conf
func_load_config () {

echo "Reading configuration from file."
if [ -f "$1" ]
then
    conf_file="$1"
else
    echo "Error: Configuration file $1 doesn't exist!"
    exit 1
fi

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

# Search for these settings from configurations file.
find_setting=( "aws_profile" )

# Process Substition example:
# https://stackoverflow.com/a/19571082
while IFS= read -r line
do
    ###########
    # This vaults parsing is not actually required, but it's left here as an
    # example if there would be need for something similar.
    ############
    # Parsing "vaults:" is a bit different process, so it has been left as own
    # "if" clause.
    # Parse "vaults:", -n checks if string is longer than zero.
    if [ -n "$(echo $line | grep '^vaults:')" ]
    then
        # Remove "vaults: (and any space/tabs)" from the beginning of line
        line=$(echo "$line" | sed 's/^vaults:[ \t]*//g')
        
        # Remove any space/tab from the line, the script will work in case,
		# the vault names are separated with comma and space.
        line=$(echo "$line" | sed 's/[ \t]*//g')
		
        # Example of creating an array of comma separated string.
		# https://stackoverflow.com/a/45201229/3498768	
        readarray -td, arr_vaults <<<"$line,"; unset 'arr_vaults[-1]'
		
        # Tip: One can check the content of arr_vaults with line:
		#declare -p arr_vaults
    
     else
        for setting in ${find_setting[@]}
        do
        # Parse "setting", -n checks if string is longer than zero.
        if [ -n "$(echo $line | grep "^$setting")" ]
        then
            # Remove "setting: (and any space/tabs)" from the beginning of line
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
    fi

done < <(echo "$conf_file")

echo "Loaded configuration:"
column -t -s "|" <<EOF
AWS profile:| $aws_profile
EOF
}

#####################################
##### DEFAULT VARIABLES
#####################################
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

# If AWS profile has not been set, don't set aws_profile_cmd
if [[ -z "$aws_profile" ]]
then
    aws_profile_cmd=""
else
    aws_profile_cmd="--profile"
fi

# How to kill a sleeping script https://askubuntu.com/a/575708/484359
echo "# To kill the script process, issue command below." > script.pid
echo "# This PID is checked with WSL, it might not work with Linux OS." >> script.pid
echo "# It's not sure what is the difference between PID \$\$ $$ and PID \$PPID $PPID" >> script.pid
echo "pkill -P $PPID" >> script.pid

echo ""
cat script.pid
echo ""

bucket_json=list-buckets_"$aws_profile"_"$datefile".json
aws "$aws_profile_cmd" "$aws_profile" s3api list-buckets > "$output_path""$bucket_json"

buckets=$(jq -r '.Buckets | .[] | (.Name)' "$output_path""$bucket_json")
mapfile -t arr_buckets <<< "$buckets"

output_csv="$output_path"bucket_"$aws_profile"_"$datefile".csv
# Header of the CSV file
echo "\"Bucket\",\"Last edited file\",\"Last edit\",\"Size of last edited file\",\"Bucket size\"" >> $output_csv

for bucket in "${arr_buckets[@]}"
do
    echo "Checking bucket: $bucket"
    modified=$(aws "$aws_profile_cmd" "$aws_profile" s3api list-objects-v2 \
        --bucket "$bucket" \
        | jq -r '.[] | max_by(.LastModified) | [.Key, .LastModified, .Size]|@csv')
    
    # If modified variable is empty, set NULLs:
    # 1st, 2nd, 3rd
    # Last edited file, Last edit, Size of the laste edited file
    if [ -z "$modified" ]
    then
        modified="\"NULL\",\"NULL\",\"NULL\""
    fi
	
    bucket_size=$(aws "$aws_profile_cmd" "$aws_profile" s3 ls s3://"$bucket" --recursive \
        | grep -v -E "(Bucket: |Prefix: |LastWriteTime|^$|--)" \
        | awk 'BEGIN {total=0}{total+=$3}END{print total/1024/1024" MB"}')

    echo "\"$bucket\","$modified,"\"$bucket_size\"" >> $output_csv
done
