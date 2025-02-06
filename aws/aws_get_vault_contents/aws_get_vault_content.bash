#!/usr/bin/env bash

# A script for retrieving contents of AWS Vault Inventories

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

# Search for these settings from configurations file.
find_setting=("account_id" "vaults" "region")

# Process Substition example:
# https://stackoverflow.com/a/19571082
while IFS= read -r line
do
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
echo "    AWS account ID: $account_id"
echo "    AWS region:     $region"
echo "    AWS Vaults: ${arr_vaults[*]}"
}

# Get ID of retrieval job.
# With the ID one can retrieve contents of Vault.
func_get_retrieval_job_id () {
    vault_name="$1"

	echo "Get retrieval job ID for $vault_name"

	aws glacier --region "$region" \
        initiate-job --account-id - \
  		--vault-name "$vault_name" \
  		--job-parameters '{"Type": "inventory-retrieval"}' \
  		> "$output_path""$vault_name"_inventory_retrieval_job.json

}

# Retrieve the vault content as JSON
func_get_vault_content_json () {
	vault_name="$1"

	jobid=$(jq -r '. | .jobId' "$output_path""$vault_name"_inventory_retrieval_job.json)

    aws glacier --region "$region" \
        get-job-output \
        --account-id "$account_id" \
        --vault-name "$vault_name" \
        --job-id "$jobid" \
        "$output_path""$vault_name"_inventory_content.json
}

# Loop through arr_vaults and get retrieval job IDs
func_start_retrieval_of_job_ids () {
    for vault in "${arr_vaults[@]}"; do
        echo "$(date --iso-8601=seconds) Started retrieving job ID: $vault"
        func_get_retrieval_job_id "$vault"
    done
}

# Loop through arr_vaults and try to get vault contents
func_retrieve_vault_contents () {
    
    # A variable which indicates if the arr_vaults_to_check needs to be
    # reconstructed without the successfully retrieved vaults.
    successful_retrieval=0

    # Temp array for reconstructing array with unsuccessful vault retrievals
    arr_retrieved_vaults=()
    #tmp_array=()

    for vault in "${arr_vaults_to_check[@]}"; do
        echo "$(date --iso-8601=seconds) Trying to retrieve vault content: $vault"
        response=$(func_get_vault_content_json "$vault")
        
        # Catching error:
        #   "An error occurred (ResourceNotFoundException) when calling the
        #   GetJobOutput operation: The job ID was not found:" 
        # Meaning: Probably the job is too old and does not exist anymore.
        err_resource_not_found_exception="ResourceNotFoundException"
        
        # Catching error:
        #   "An error occurred (InvalidParameterValueException) when calling
        #   the GetJobOutput operation: The job is not currently available for download:"
        # Meaning: Probably the job is not ready yet.
        err_invalid_parameter_value_exception="InvalidParameterValueException"
        
        # A helper variable to determine the status of the http response
        http_status=$(echo "$response" | jq '. | .status' 2> /dev/null)
        
        if echo "$response" | grep "$err_resource_not_found_exception" > /dev/null
        then
            echo "$(date --iso-8601=seconds) ERROR: $response"
            exit 1
        
        elif echo "$response" | grep "$err_invalid_parameter_value_exception" > /dev/null
        then
            echo "$(date --iso-8601=seconds) INFO: The job is not ready yet. $response"

        # If the response is status=200, then the retrieval was successful and
        # the vault can be removed from the arrays to be checked.
        # Redirect both stdout and stderr into /dev/null, so nothing is printed on screen,
        # otherwise jq will print error when checking the response of previous messages.
        elif [ "$http_status" = "200" ]
        then
            successful_retrieval=1
            arr_retrieved_vaults+=($vault)
            echo "$(date --iso-8601=seconds) Retreival was succesful: $vault"
        fi
    done

    # If at least one vault content retrieval was successful,
    # override arr_vaults_to_check array with a new array that has arrays left.
    if [ "$successful_retrieval" -eq 1 ]
    then
        # Temp array
        arr_not_retrieved_vaults=()

        # Add vaults that haven't checked yet.
        for vault in "${arr_vaults_to_check[@]}"
        do
            # A helper variable to determine if the vault has been retrieved
            # already.
            has_been_retrieved=0
            
            # Loop through retrieved_vaults and mark if vault has been
            # retrieved.
            for retrieved_vault in "${arr_retrieved_vaults[@]}"
            do
                [[ "$retrieved_vault" == "$vault" ]] && has_been_retrieved=1
            done

            # If the vault was not retrieved yet, add it into
            # arr_not_retrieved_vaults array.
            if [ "$has_been_retrieved" -eq 0 ]
            then
                arr_not_retrieved_vaults+=($vault)
            fi
        done
        arr_vaults_to_check=("${arr_not_retrieved_vaults[@]}")
        unset arr_not_retrieved_vaults
    fi
    
    unset tmp_array
    unset arr_retrieved_vaults
}

# A function for retrying to retrieve vault contents.
# Arguments:
#   1st = how many times the vault content is tried to be retrieved
#   2nd = how long should be waited between retries
func_loop_for_vault_contents () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No try_count as 1st argument supplied." && exit 1
    [ -z "$2" ] && echo "ERROR: No wait_time as 2nd argument supplied." && exit 1

    try_count="$1"
    wait_time="$2"

    n=0
    until [[ "$n" -ge "$try_count" || ! (( ${#arr_vaults_to_check[@]} )) ]]
    do
        func_retrieve_vault_contents
        
        ((n++))
       
        # Check that the try_count is not over. Otherwise in the last round
        # there would be wait without anything happening afterwards.
        #if [ "$n" -lt "$try_count" ]; then
            
        # If there are vaults whom contents have not been found and
        # not over the try_count otherwise in the last round nothing would
        # happen.
        if (( ${#arr_vaults_to_check[@]} )) && [ "$n" -lt "$try_count" ]; then
            printf "\nRetrying in $wait_time seconds" 

            # Printing dot every ? seconds to show that something is happening.
            i=0
            sleeping=5
            until [ "$i" -ge "$wait_time" ]
            do
                sleep "$sleeping" >&1
                printf "."
                let i="$i + $sleeping"
            done

            printf "\n"
        fi
    done
}

#####################################
##### DEFAULT VARIABLES
#####################################
arr_vaults=()
account_id="empty"
region="empty"

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

echo "$(date --iso-8601=seconds) #### Script started #### "

# Read vaults from conf file
func_load_config "$config_file"

# How to kill a sleeping script https://askubuntu.com/a/575708/484359
echo "# To kill the script process, issue command belwo:" > script.pid
echo "# This PID is checked with WSL, it might not work with Linux OS." >> script.pid
echo "# Not sure if there is difference with this PID $$ and this PID $PPID" >> script.pid
echo "pkill -P $PPID" >> script.pid

echo ""
cat script.pid
echo ""

# Start the retrieval job IDs
func_start_retrieval_of_job_ids

# Creating a copy of vault array, so the copy can be modified
arr_vaults_to_check=("${arr_vaults[@]}")

# Get the vault contents
# 1st argument = how many tries
# 2nd argument = how long should be waited between retries in seconds
# The retrieval takes hours, so checking every 1h (3600 seconds) makes sense.
func_loop_for_vault_contents 6 3600

if (( ${#arr_vaults_to_check[@]} ))
then
    echo "    AWS Vaults not retrieved: ${arr_vaults_to_check[*]}"
fi

exit 0
