#!/bin/bash

# This script will create TAR files from the subdirs/files in a given directory.
# Every subdir and file will be a separete TAR file.

if [ -z "$1" ]
then
    echo "No list of files/folders to compress given."
    echo "Usage:"
    echo "./script.sh /path/to/dir"
    exit 1
fi

# Subdirs / files in the path will be put into separate tar files.
path_content="$1"
datefile=$(date +"%Y-%m-%d_%H-%M")
# Remember trailing forwardslash / in the output dir
output_dir="/tmp_tar/"
s3_destination="BUCKET_NAME/tar_balls/$datefile/"
# Limit rate that this script is not using all CPU.
# Check "man pv" and entry -L for more information
rate_limit="20m"

# Required packages for run the script
arr_packages=("pv")

# Function to check if all necessary packages to run this script
# have been installed.
func_check_required_packages () {
    for package in ${arr_packages[@]}
    do
        local require_package_install="false"
        # Check that the required packages are installed
        if ! command -v "$package" &> /dev/null
        then
            echo "Package $package could not be found. Please install $package"
            require_package_install="true"
        fi

    done

    if [[ "$require_package_install" == "true" ]]
    then
        exit 1
    fi
}

readarray -t arr_compress <<< "$(find $path_content -maxdepth 1 -printf '%P\n')"

# Remove the first empty element
unset 'arr_compress[0]'

func_tar_upload () {
    # Reference the array correctly (not tmp_array="$1" )
    tmp_array=("$@")

    for (( i=0; i<${#tmp_array[@]}; i++ ))
    do
        local package="${tmp_array[$i]}"

        # Create tar. There's no need to gzip, because the packages are usually
        # already compressed.
        tar -cvf - "$path_content"/"$package" | pv -L "$rate_limit" >"$output_dir""$package".tar

        aws s3 mv "$output_dir""$package".tar s3://"$s3_destination"
    done
}


#####################################
##### SCRIPT MAIN
#####################################

func_check_required_packages

func_tar_upload "${arr_compress[@]}"
