$users = "BUILTINT\users"
$folder = "C:\shared for all users"

echo "#### ACL before change ####"
Get-Acl $folder | fl

### Change ACL ###
$acl = Get-Acl $folder

# Even though it's weird None flag with combination of ContainerInherit,ObjectInherit will apply the "Modify" permission to "This Folder, Sublfolders and Files" 
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\users","Modify","ContainerInherit,ObjectInherit","None","Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl $folder

echo "#### ACL after change ####"
echo "This doesn't actually necessarily show any change..."
Get-Acl $folder | fl
