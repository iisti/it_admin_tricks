# AWS Remove Objects from Glacier

## How to use

### Retrieve Glacier Vault content
* [AWS Get Vault Contents](../aws_get_vault_contents/)


## Remove some objects/files
* Retrieve object/VM names from inventory JSON into a file without prefix.
    ~~~
    # Variables for automation
    vault_name="MY_VAULT_NAME"
    inventory_content_json="$vault_name"_inventory_content.json

    # Get object/file names without path/prefix. This way it's easier to control
    # what you're removing. The path/prefix will be defined in config.conf
    jq -r '.ArchiveList[] | .ArchiveDescription' $inventory_content_json | \
        awk -F/ '{ print $NF }' | awk -F'"' '{print $1}' > "$vault_name".txt
    ~~~

## Remove whole vault
* If you want to remove the whole vault, use this to create a text file of to be removed files.
    ~~~
    # Variables for automation
    vault_name="MY_VAULT_NAME"
    inventory_content_json="$vault_name"_inventory_content.json

    # Get object/file names with full path
    jq -r '.ArchiveList[] | .ArchiveDescription' $inventory_content_json | \
        awk -F\" '{ print $4 }' > "$vault_name".txt
    ~~~

## How to compare what is found in the vault to another list of files
* MY_VAULT_NAME.txt contains objects in the glacier vault.
* compare_with_these_objects.txt contains list of file names to compare.
* Convert Newlines chars into same format before comparison, if you're using diffent operating systems
  * https://www.cyberciti.biz/faq/howto-unix-linux-convert-dos-newlines-cr-lf-unix-text-format/
    ~~~ 
    dos2unix MY_VAULT_NAME.txt
    dos2unix compare_with_these_objects.txt
    comm -12 <( sort MY_VAULT_NAME.txt ) <( sort compare_with_these_objects.txt )

    # -1 suppresses unique lines of the 1st file
    # -2 suppresses unique lines of the 2nd file
    ~~~

## Use the removal script
1. Configure `config.ini`
1. Run the script `./aws_rem_objs_glacier.bash`
