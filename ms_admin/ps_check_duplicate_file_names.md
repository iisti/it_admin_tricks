# Check for duplicate file names via PowerShell

## Simple duplicate file name check
  * This PowerShell script checks only for duplicate filenames, not for modify date, file size... 
  ~~~
  $output_path="d:\"
  $check_path="d:\folder_name\"

  $arr_fnames = (get-childitem $check_path -recurse)

  $files_by_name = @{}

  foreach($file in $arr_fnames){
      $files_by_name[$file.Name] += @($file)
  }

  $files_by_name

  foreach($file_name in $files_by_name.Keys){
      if($files_by_name[$file_name].Count -gt 1){
          write-host "Duplicates found!"
          $files_by_name[$file_name] |Select -Expand FullName |Add-Content "$output_path\duplicates.txt"
      }
  }
  ~~~
