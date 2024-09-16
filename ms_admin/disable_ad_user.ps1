# Script for disabling AD user and appending "Disabled on dd.MM.yyyy" to account's description.

do {
$search_base = "OU=ou,DC=domain,DC=com"
    $date = Get-Date -Format "dd.MM.yyyy"
    $user = Read-Host -Prompt 'Input sAMAccountName to be disabled, exit with 0'

    if (!(Get-ADUser -Filter {sAMAccountName -eq $user})) {
        Write-Host "User does not exist."
    }
    elseif (!(Get-ADUser -Filter {sAMAccountName -eq $user}).Enabled) {
        Write-Host "User is already disabled."
    }
    else {
        # Append "Disabled on $date" to user's description
        Get-ADUser -Filter {sAMAccountName -eq $user} -Properties Description |
            ForEach-Object {
                Set-ADUser $_ -Description "$($_.Description) Disabled on $date" }

        # Disable the user
        Get-ADUser -Filter {sAMAccountName -eq $user} -SearchBase $search_base | Disable-ADAccount

        # Print the user. properties variable is used, so that the command doesn't grow long.
        $properties = 'mail,Name,sAMAccountName,ObjectClass,Enabled,LastLogonTimestamp,LastLogonDate,description' -split ','
        Get-ADUser -Filter {sAMAccountName -eq $user} -SearchBase $search_base -Properties $properties |
            Select $properties
    }
# Exit when user input is 0
} until ($user -eq "0")
