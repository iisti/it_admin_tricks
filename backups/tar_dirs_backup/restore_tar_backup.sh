#!/bin/bash

# Script for untarring files and folders in the a directory.
# This script can handle only one * asterisk in the file path, e.g.
# /path/*/to/content
# or
# /path/to/content/*

#####################################
#### INIT
#####################################

if [ -z "$1" ]
then
    echo "No config file given."
    echo "Usage:"
    echo "./script.sh /path/to/config_file"
    exit 1
fi

datefile=$(date +"%Y-%m-%d_%H-%M")

# Import configuration file
source "$1"

# Required packages for run the script
arr_packages=("pv tar")

#####################################
#### FUNCTIONS
#####################################

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

func_untar () {
    # Reference the array correctly (not tmp_array="$1" )
    tmp_array=("$@")

    for (( i=0; i<${#tmp_array[@]}; i++ ))
    do
        local package="${tmp_array[$i]}"

        # Extract tar.
        # pv limits rate. Check "man pv"
        pv -L "$rate_limit" "$path_content"/"$package" | tar xv -C "$output_dir"
    done
}

func_remove_excluded() {
    for exclude in "${arr_exclude[@]}"; do
        for i in "${!arr_tar[@]}"; do
            if [[ ${arr_tar[i]} = $exclude ]]; then
                unset 'arr_tar[i]'
            fi
        done
    done

    # Rebuild the array, so there are no missing indexes.
    for i in "${!arr_tar[@]}"; do
        arr_tmp+=( "${arr_tar[i]}" )
    done
    arr_tar=("${arr_tmp[@]}")
    unset arr_tmp

    echo "Print files and folders to be tarred."
    declare -p arr_tar
}

# Function for creating an array of content paths.
# Tar cannot handle asterisk, so this must be done.
func_replace_asterisk_with_real_path() {
    if [[ "$path_content" == *'*'* ]]
    then
        echo "There's at least one * asterisk in the file path."
        echo "Notice that this script can handle only one asterisk!"
        echo "Only the alphabetically first directory will be used when replacing the asterisk!"
        echo "Replacing the asterisk with actual directory"
        asterisk_in_path="true"
        
        # Remove last asterisk and everything after it.
        tmp_path=${path_content%\**}
        
        # Create arrays of the tmp_path
        readarray -t arr_paths <<< "$(find $tmp_path -maxdepth 1 -printf '%P\n')"
        
        # Remove the first empty element
        unset 'arr_paths[0]'

        echo "Which paths are found? If there are more than one there might be an issue."
        declare -p arr_paths

        if [[ ${#arr_paths[@]} -gt 1 ]]
        then
            echo "WARNING: There are more than 1 path. The script might not work as expected!"
        fi

        # Replace asterisk with actual folder name
        echo "Replace * asterisk with ${arr_paths[1]}"
        path_content="${path_content/\*/${arr_paths[1]}}"
    fi
}

#####################################
#### VARIABLES
#####################################

readarray -t arr_tar <<< "$(find $path_content -maxdepth 1 -printf '%P\n')"

# Remove the first empty element
unset 'arr_tar[0]'

# exclude is defined in config file
readarray -t arr_exclude < "$exclude"

# Create path array for replacing 
arr_paths=()

asterisk_in_path="false"

#####################################
##### SCRIPT MAIN
#####################################

echo "Check required packages"
func_check_required_packages

echo "Remove excluded"
func_remove_excluded

echo "Check for asterisk in file path and replace it if found"
func_replace_asterisk_with_real_path

echo "Untar the files and folders to destinated path"
func_untar "${arr_tar[@]}"