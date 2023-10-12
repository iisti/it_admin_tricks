# AWK tricks

## Going through CSV file and trimming information
* Example CSV file containing VM information
    ~~~
    Provider,Project,Zone,VM Name,Public IPs,Private IPs,State,Size,Image,ID
    GCP,project-name01,europe-north1-a,vm01,33.228.210.172,10.167.15.234,stopped,custom-2-11520,centos-7-v20191014,1085018649382451111
    GCP,project-name01,europe-north1-a,vm02,33.228.142.89,10.167.15.243,stopped,n1-standard-1,centos-7-v20191014,2012940715864321111
    GCP,project-name01,europe-north1-a,vm03,33.228.226.42,10.167.0.11,running,n1-standard-1,vm03-new,128026792538951111
    ~~~
* Command for pretty print and trimming the information
    ~~~
    csv="vms_20210616.csv"; \
    arr=(vm01 vm03); \
    echo "Provider,Project,Zone,VM Name,Public IPs,Private IPs,State,Size,Image,ID" | \
        awk -F',' '{ printf "%-25s %-25s %-25s %-25s %-25s %-25s\n", $2,$3,$4,$5,$6,$7 }'; \
    for vm in "${arr[@]}"; do awk -F',' -v pat="$vm" '{ if($4 ~ pat ) printf "%-25s %-25s %-25s %-25s %-25s %-25s\n", $2,$3,$4,$5,$6,$7 }' "$csv"; done
    ~~~
    * Explanations
        ~~~
        csv       = CSV file
        arr       = array of VM names which want to be printed
        echo line = header line
        for line  = goes through the CSV and pickus up relevant information
        ~~~
* Output
    ~~~
    Project                   Zone                      VM Name                   Public IPs                Private IPs               State
    project-name01            europe-north1-a           vm01                      33.228.210.172            10.167.15.234             stopped
    project-name01            europe-north1-a           vm03                      33.228.226.42             10.167.0.11               running
    ~~~

## Search for VMs with status "running" in CSV files
* Scenario: there are multiple CSV files containig similar information as in the example above. User wants to print the running VMs.
    ~~~
    vms_20210614.csv
    vms_20210615.csv
    vms_20210616.csv
    ~~~
* Command for checking the running VMs
    ~~~
    awk -F',' -v pat="running" '{ if( $7 == pat ) print FILENAME, $4, $7 }' ./vms_* | tail -n 1
    ~~~
    * Explanations
        ~~~
        -F                  = separator
        -v                  = variable
        if( $7 == pat )     = if column 7 is variable pat
        ~~~
* Output: filename vm_name status
    ~~~
    ./vms_20210616.csv vm03 running
    ~~~
