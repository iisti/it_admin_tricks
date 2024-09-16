#!/bin/bash

# Delete entire versioned directory in S3.
# Based on Gist https://gist.github.com/sdarwin/dcb4afc68f0952ded62d864a6f720ccb

# Reset in case getopts has been used previously in the shell.
OPTIND=1

####################
# FUNCTIONS
####################

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

# Help screen
function func_show_help() {
  cmd=$(basename $0)
  echo "Usage: ${cmd} <options> where options are:"
  echo " -h               Show this message"
  echo " -b <bucket>      Bucket name"
  echo " -p <prefix>      Prefix"
  echo " -u [profile]     Profile, optional"
  echo " -o               Remove objects"
  echo " -d               Remove delete markers"
  echo " -a               Remove all"
  echo
  echo "Example: ${cmd} -b bucket -p prefix"
}

# Remove objects
function func_remove_objects() {
    echo "" >> "$output"results_remove_objects_"$datefile".json
    lines1=0
    lines2=1

    while [ "$lines1" -lt "$lines2" ]
    do
        # Save the amount of lines in results to variable
        lines1=$(wc -l "$output"results_remove_objects_"$datefile".json | cut -d' ' -f1)
        
        # Create JSON of objects to remove
        aws s3api list-object-versions \
            $profile_cmd $profile \
            --max-items 999 \
            --bucket "$bucket_name" \
            --prefix "$prefix" \
            --output=json \
            --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > "$output"remove_objects_"$datefile".json

        # Check if there's something to remove
        check_null=$(jq -r '.Objects' "$output"remove_objects_"$datefile".json)
        if [  "$check_null" != "null" ]
        then
            # Delete objects
            aws s3api delete-objects \
                $profile_cmd $profile \
                --cli-connect-timeout "$cli_timeout" \
                --bucket "$bucket_name" \
                --delete file://"$output"remove_objects_"$datefile".json >> "$output"results_remove_objects_"$datefile".json

            # Save the amount of lines in results to a new file for comparison
            lines2=$(wc -l "$output"results_remove_objects_"$datefile".json  | cut -d' ' -f1)

            # Update count of how many objects have been removed in the screen
            removed_count=$(jq -r '.Deleted[].Key' "$output"results_remove_objects_"$datefile".json | wc -l)
            echo "Removed till now: $removed_count"
        else
            echo "Nothing left to remove"
        fi
    done
}

# Remove delete markers
function func_remove_delete_markers() {
    echo "" >> "$output"remove_delete_markers_"$datefile".json
    lines1=0
    lines2=1
    split=0

    while [ "$lines1" -lt "$lines2" ] || [ "$split" -eq 1 ]
    do
        # Save the amount of lines in results to variable
        lines1=$(wc -l "$output"remove_delete_markers_"$datefile".json | cut -d' ' -f1)

        # Create JSON of delete markers
        aws s3api list-object-versions \
            $profile_cmd $profile \
            --max-items 999 \
            --bucket "$bucket_name" \
            --prefix "$prefix" \
            --output=json \
            --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > "$output"remove_delete_markers_temp_"$datefile".json

        # Check if there's something to remove
        check_null=$(jq -r '.Objects' "$output"remove_delete_markers_temp_"$datefile".json)
        if [  "$check_null" != "null" ] ; then
            # There will be an error if the json is too big, so it needs to be split.
            # "An error occurred (MalformedXML) when calling the DeleteObjects operation: The XML you provided was not well-formed or did not validate against our published schema"
            lines=$(wc -l "$output"remove_delete_markers_temp_"$datefile".json | cut -d" " -f1)
            #echo "$lines number of lines in response. The removal needs to be split."
            if [ $lines -gt 3997 ]; then
                head -n 3997 "$output"remove_delete_markers_temp_"$datefile".json > "$output"remove_delete_markers_"$datefile".json
                echo "        } ] }" >> "$output"remove_delete_markers_"$datefile".json

                split=1
            else
                head -n 3997 "$output"remove_delete_markers_temp_"$datefile".json > "$output"remove_delete_markers_"$datefile".json
                split=0
            fi

            # Remove delete markers
            aws s3api delete-objects \
                $profile_cmd $profile \
                --cli-connect-timeout "$cli_timeout" \
                --bucket "$bucket_name" \
                --delete file://"$output"remove_delete_markers_"$datefile".json >> "$output"results_remove_delete_markers_"$datefile".json

            # Save the amount of lines in results to a new file for comparison
            lines2=$(wc -l "$output"remove_delete_markers_"$datefile".json  | cut -d' ' -f1)

            # Update count how many left to remove of the delete markers
            left_to_rem=$(jq -r '.Objects[].Key' "$output"remove_delete_markers_temp_"$datefile".json | wc -l)
        else
            left_to_rem=0
        fi
        echo "Left to remove: $left_to_rem"
    done
}

####################
# VARIABLES
####################
#bucket_name="backup-it-01"
#prefix="inf-artifactory01/backup-daily/current/"
datefile=$(date +"%Y-%m-%d_%H-%M-%S")

cli_timeout=600

# Script path
script_path=$(func_get_script_source_dir)

# Output path
mkdir -p "$script_path"/output
output="$script_path"/output/

# Default values
rem_objs=0
rem_markers=0
rem_all=0

#################
# MAIN
#################

# Parse options
while getopts "h?:b:p:u:oda" opt; do
  case "$opt" in
  h|\?)
    func_show_help
    exit
    ;;
  b) bucket_name=${OPTARG};;
  p) prefix=${OPTARG};;
  u) profile=${OPTARG};;
  o) rem_objs=1;;
  d) rem_markers=1;;
  a) rem_all=1;;
  esac
done

# Get rid of the just-finished flag arguments
# https://unix.stackexchange.com/questions/214141/explain-the-shell-command-shift-optind-1
shift "$((OPTIND - 1))"

# Check mandatory options
if [[ -z "${bucket_name}" ]]; then
  echo "No bucket set. Use -b <bucket>"
  exit 1
fi

if [[ -z "${prefix}" ]]; then
  echo "No prefix set. Use -p <prefix>"
  exit 1
fi

# If AWS profile has not been set, don't set aws_profile_cmd
if [[ -z "$profile" ]]
then
    profile_cmd=""
else
    profile_cmd="--profile"
fi

# How to kill a script https://askubuntu.com/a/575708/484359
echo "# To kill the script process, issue command below:" > script.pid
echo "# This PID is checked with WSL, it might not work with Linux OS." >> script.pid
echo "# Not sure if there is difference with this PID $$ and this PID $PPID" >> script.pid
echo "pkill -P $PPID" >> script.pid

echo ""
cat script.pid
echo ""

if [ "$rem_objs" -eq 1 ] || [ "$rem_all" -eq 1 ]
then
    echo "Removing objects"
    func_remove_objects
fi

if [ "$rem_markers" -eq 1 ] || [ "$rem_all" -eq 1 ]
then
    echo "Removing delete markers"
    func_remove_delete_markers
fi
