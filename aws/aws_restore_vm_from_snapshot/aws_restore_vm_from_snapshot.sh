#!/usr/bin/env bash

# A script for restoring Windows VM via AWS CLI

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
find_setting=(\
    "aws_profile" \
    "instance_id" \
    "region" \
    "original_working_snapshot" \
    "latest_snapshot_r" \
    "new_disk_name_r" \
    "dev_name_r" \
    "latest_snapshot_01" \
    "new_disk_name_01" \
    "dev_name_01")

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
AWS instance ID:| $instance_id
AWS region:| $region
AWS original working snapshot:| $original_working_snapshot
AWS latest working snapshot of root volume:| $latest_snapshot_r
AWS new root volume name:| $new_disk_name_r_$(date +"%Y-%m-%d_%H-%M")
AWS root device name:| $dev_name_r
AWS latest working snapshot of data volume 01:| $latest_snapshot_01
AWS new data volume 01 name:| $new_disk_name_01_$(date +"%Y-%m-%d_%H-%M")
AWS data device 01 name:| $dev_name_01
EOF
}

# Sleep 
# Arguments:
#   1st = how long should be waited between retries in seconds
func_sleep () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No wait_time as 1nd argument supplied." && exit 1
    
    wait_time="$1"

    printf "\nRetrying in $wait_time seconds" 
    
    # Printing dot every ? seconds to show that something is happening.
    i=0
    #sleeping=5
    until [ "$i" -ge "$wait_time" ]
    do
        #sleep "$sleeping" >&1
        sleep 1 >&1
        printf "."
        let i="$i + 1"
    done
    
    printf "\n"
}

# Wait till the VM has stopped
# Arguments:
#   1st = how many retries
#   2nd = how long should be waited between retries
func_wait_vm_stopped () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No try_count as 1st argument supplied." && exit 1
    [ -z "$2" ] && echo "ERROR: No wait_time as 2nd argument supplied." && exit 1

    try_count="$1"
    wait_time="$2"

    n=0
    until [[ "$n" -ge "$try_count" || "$i_state" == "stopped" ]]
    do
        ((n++))

        i_state=$(aws "$aws_profile_cmd" "$aws_profile" ec2 describe-instances \
            --instance-ids "$instance_id" | \
            jq -r '.Reservations[0].Instances[0].State.Name')

        if [[ "$i_state" == "stopped" ]]
        then
            echo "Instance has stopped."
        else
            echo "State: $i_state"
            func_sleep "$wait_time"
        fi
    done
}

# Get instance description/details
func_describe_instance () {
    aws "$aws_profile_cmd" "$aws_profile" ec2 describe-instances --instance-ids "$instance_id"
}

# Detach a volume
# Arguments:
#   1st = how many retries
#   2nd = how long should be waited between retries
#   3rd = volume ID to be detached
func_detach_volume () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No try_count as 1st argument supplied." && exit 1
    [ -z "$2" ] && echo "ERROR: No wait_time as 2nd argument supplied." && exit 1
    [ -z "$3" ] && echo "ERROR: No vol_id as 3nd argument supplied." && exit 1

    local try_count="$1"
    local wait_time="$2"
    local vol_id="$3"

    local n=0
    until [[ "$n" -ge "$try_count" || "$detach_state" == "detaching" ]]
    do
        ((n++))

        local detach_status=$(aws "$aws_profile_cmd" "$aws_profile" ec2 detach-volume \
            --volume-id "$vol_id")
        echo "detach status:"
        echo "$detach_status"
        local detach_state=$(jq -r '.State' <<< $detach_status)

        if [[ "$detach_state" == "detaching" ]]
        then
            echo "Volume is being detached."
        else
            echo "$detach_status"
            func_sleep "$wait_time"
        fi
    done
}

func_detach_volume_and_get_vol_zone () {
    local vol_id=$1
    if [[ "$vol_id" == "null" ]]
    then
        echo "Volume ID is $vol_id. Cannot detach volume."
    else
        echo "Detaching volume $vol_id"
        func_detach_volume 20 5 "$vol_id"
        
        echo "Checking original volume zone:"
        vol_zone=$(aws "$aws_profile_cmd" "$aws_profile" ec2 describe-volumes \
            --volume-ids "$vol_id" \
            | jq -r ".Volumes[0].AvailabilityZone")
        echo "$vol_zone"
    fi
}

# Wait till volume is available
# Arguments:
# $1 = how many retries
# $2 = wait time in seconds
# $3 = volume ID
func_wait_volume_available () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No try_count as 1st argument supplied." && exit 1
    [ -z "$2" ] && echo "ERROR: No wait_time as 2nd argument supplied." && exit 1
    [ -z "$3" ] && echo "ERROR: No vol_id as 3nd argument supplied." && exit 1

    local try_count="$1"
    local wait_time="$2"
    local vol_id="$3"

    n=0
    until [[ "$n" -ge "$try_count" || "$volume_state" == "available" ]]
    do
        ((n++))

        volume_description=$(aws $aws_profile_cmd $aws_profile ec2 describe-volumes \
            --volume-ids "$vol_id ")
        volume_state=$(jq -r '.Volumes[0].State' <<< $volume_description)

        if [[ "$volume_state" == "available" ]]
        then
            echo "Volume is available."
        else
            echo "Volume state: $volume_state"            
            func_sleep "$wait_time"
        fi
    done
}

# Wait till volume is attached / in-use
# Arguments:
# $1 = how many retries
# $2 = wait time in seconds
# $3 = volume ID
func_wait_volume_attached () {
    # Check that args are given
    [ -z "$1" ] && echo "ERROR: No try_count as 1st argument supplied." && exit 1
    [ -z "$2" ] && echo "ERROR: No wait_time as 2nd argument supplied." && exit 1
    [ -z "$3" ] && echo "ERROR: No vol_id as 3nd argument supplied." && exit 1

    local try_count="$1"
    local wait_time="$2"
    local vol_id="$3"

    echo "Waiting till volume state is \"in-use\"."

    n=0
    until [[ "$n" -ge "$try_count" || "$volume_state" == "in-use" ]]
    do
        ((n++))

        volume_description=$(aws $aws_profile_cmd $aws_profile ec2 describe-volumes \
            --volume-ids "$vol_id ")
        volume_state=$(jq -r '.Volumes[0].State' <<< $volume_description)

        echo "Volume state: $volume_state"            
        
        if [[ "$volume_state" != "in-use" ]]
        then
            func_sleep "$wait_time"
        fi
    done
}

# Check that the config file is valid
# Arguments:
#   1st = how many retries
func_check_config_file () {
    # Configuration file
    if [[ -z $1 ]]
    then
        config_file="$script_path/config.conf"
    else
        config_file="$script_path/$1"
    fi

    if [[ ! -f "$config_file" ]]
    then
        echo "Configuration file $config_file doesn't exist!"
        exit 1
    fi
}

# Create a volume from working snapshot.
# Arguments:
# $1 = snapshot ID
# $2 = new disk name
# $3 = volume zone
# $4 = tag01 for allowing working with the snapshot
func_create_vol_from_snap () {
    local snap_id="$1"
    local new_disk_name="$2"
    local vol_zone="$3"
    local tag01="$4"
    local create_vol_output="null"

    # Attention! tmp_vol_id variable needs to be created in the parent function,
    # before calling func_create_vol_from_snap, like:
    # local tmp_vol_id

    if [[ "$vol_zone" == "null" ]]
    then
        echo "Volume Zone is $vol_zone. Cannot create a new volume from the latest snapshot."
        exit 1
    else
        echo "Creating volume:"
        create_vol_output=$(aws "$aws_profile_cmd" "$aws_profile" ec2 create-volume \
            --availability-zone "$vol_zone" \
            --volume-type gp3 \
            --snapshot-id "$snap_id" \
            --tag-specifications \
                "ResourceType=volume,Tags=[{Key=Name,Value=$new_disk_name},{$tag01}]")
        echo "$create_vol_output"
        tmp_vol_id=$(jq -r '.VolumeId' <<< $create_vol_output)
    fi
}

# Attach volume
# Arguments:
# $1 = volume ID
# $2 = device name
func_attach_volume () {
    local vol_id="$1"
    local dev_name="$2"
    
    aws "$aws_profile_cmd" "$aws_profile" ec2 attach-volume \
        --device "$dev_name" \
        --instance-id "$instance_id" \
        --volume-id "$vol_id"
}

func_add_time_stamp_vol_name () {
    echo "$1"_$(date +"%Y-%m-%d_%H-%M")
}

# arg block dev index
func_check_vol_id () {
    block_dev_num="$1"
    echo $(jq -r ".Reservations[0].Instances[].BlockDeviceMappings[$block_dev_num].Ebs.VolumeId" \
        <<< $i_description)
}


# Attach volume
# Arguments:
# $1 = snapshot ID
# $2 = volume name
# $3 = device name
func_process_new_vol () {
    local snap_id="$1"
    local vol_name="$2"
    local dev_name="$3"
    local tag01="$4"

	local tmp_vol_id="empty"
	func_create_vol_from_snap "$snap_id" "$vol_name" "$vol_zone" "$tag01"
    echo "New volume ID:"
    echo "$tmp_vol_id"

    echo "Waiting that volume becomes available: $tmp_vol_id"
    func_wait_volume_available 20 5 "$tmp_vol_id"

    echo "Attaching new volume."
    func_attach_volume "$tmp_vol_id" "$dev_name"
    
    echo "Waiting that the volume is attached properly: $tmp_vol_id"
    func_wait_volume_attached 20 5 "$tmp_vol_id"
}

#####################################
##### DEFAULT VARIABLES
#####################################
instance_id="empty"
region="empty"
original_working_snapshot="empty"
latest_snapshot_r="empty"
new_disk_name_r="empyt"
dev_name_r="empty"
latest_snapshot_01="empty"
new_disk_name_01="empty"
dev_name_01="empty"



# Script path
script_path=$(func_get_script_source_dir)

# Output path
mkdir -p "$script_path"/output
output_path="$script_path"/output/

# Config file
config_file="empty"

vol_zone="null"

tag01="Key=restore-vm-from-snapshot,Value=true"
#####################################
##### SCRIPT MAIN
#####################################

echo "$(date --iso-8601=seconds) #### Script started #### "

func_check_config_file $1
echo "Configuration file: $config_file"
# Read vaults from conf file
func_load_config "$config_file"

# Adding timestamp to the disk name "_2022-11-16_15-32"
new_disk_name_r=$(func_add_time_stamp_vol_name $new_disk_name_r)
echo "new_disk_name_r: $new_disk_name_r"

if [[ "$new_disk_name_01" != "empty" ]]
then
    new_disk_name_01=$(func_add_time_stamp_vol_name $new_disk_name_01)
    echo "new_disk_name_01: $new_disk_name_01"
fi

# If AWS profile has not been set, don't set aws_profile_cmd
if [[ -z "$aws_profile" ]]
then
    aws_profile_cmd=""
else
    aws_profile_cmd="--profile"
fi

# How to kill a sleeping script https://askubuntu.com/a/575708/484359
echo "# To kill the script process, issue command belwo:" > script.pid
echo "# This PID is checked with WSL, it might not work with Linux OS." >> script.pid
echo "# Not sure if there is difference with this PID $$ and this PID $PPID" >> script.pid
echo "pkill -P $PPID" >> script.pid

echo ""
cat script.pid
echo ""

# Stop the VM
echo "Stopping $instance_id"
aws "$aws_profile_cmd" "$aws_profile" ec2 stop-instances --instance-ids "$instance_id" | \
    tee -a "$logfile"

# Check status of the VM. Waiting that it's stopped.
echo "Checking instance status:"
func_wait_vm_stopped 20 20

# Get instance information
echo "Describe instance:"
i_description=$(func_describe_instance)
echo "$i_description"



echo "### Root volume operations:"
# Root volume operations
if [[ "$new_disk_name_r" != "empty" ]]
then
    echo "Checking original volume ID:"
    orig_vol_id_r=$(func_check_vol_id "0")
    echo "$orig_vol_id_r"

    # Detach volume and get volume zone
    func_detach_volume_and_get_vol_zone "$orig_vol_id_r"

    echo "Creating a new volume and attaching it as root"
    func_process_new_vol "$latest_snapshot_r" "$new_disk_name_r" "$dev_name_r" "$tag01"
else
    echo "ERROR: No root volume name configured!"
fi

echo "### Secondary volume operations:"
# Secondary volume operations
if [[ "$new_disk_name_01" != "empty" ]]
then
    echo "Checking original volume ID:"
    orig_vol_id_01=$(func_check_vol_id "1")
    echo "$orig_vol_id_01"
    
    func_detach_volume_and_get_vol_zone "$orig_vol_id_01"
    
    echo "Creating a new volume and attaching it as volume 01"
    func_process_new_vol "$latest_snapshot_01" "$new_disk_name_01" "$dev_name_01" "$tag01"
else
    echo "WARNING: No secondary volume name configured!"
fi

# Start the VM
echo "Starting the VM: $instance_id"
aws "$aws_profile_cmd" "$aws_profile" ec2 start-instances --instance-ids "$instance_id"

exit 0
