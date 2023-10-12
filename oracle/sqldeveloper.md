# Instructions for Oracle SQL Developer
* Version 20.2 was used originally to create these instructions.

## Installation
* Downlaod and install Oracle JDK
  * https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html
* Download SQL Developer for free, it requires free registration to Oracle website.
  * https://www.oracle.com/tools/downloads/sqldev-downloads.html
### Windows configurations
* Configure the program to use English (or another language) by adding lines below to file %USERPROFILE%\AppData\Roaming\sqldeveloper\<version>\product.conf

      # Use English
      AddVMOption -Duser.language=en
* One can also start the SQL Developer with different languages

      sqldeveloper.exe --AddVMOption=-Duser.language=en

  * One can create a shortcut to the original sqldeveloper.exe, right click the shortuct and set Target as:
    ~~~
    C:\sqldeveloper\sqldeveloper.exe --AddVMOption=-Duser.language=en
    ~~~ 
  * Or one can make a PowerShell scripts for starting SQL Developer with different languages.
    * Create file `sqldeveloper_start_english.ps1` with content below into the same directory where the sqldeveloper.exe resideds.  
      ~~~
      ./sqldeveloper.exe --AddVMOption=-Duser.language=en
      ~~~

## Check Oracle database size
* Source https://asktom.oracle.com/pls/apex/f?p=100:11:::::P11_QUESTION_ID:9529533800346071500
* The size of the database is the space the files physically consume on disk. You can find this with:

      # Megabytes
      select sum(bytes)/1024/1024 size_in_mb from dba_data_files;
      # Gigabytes
      select sum(bytes)/1024/1024/1024 size_in_gbytes from dba_data_files;
      
* But not all this space is necessarily allocated. There could be sections of these files that are not used.
* You can find the total space that is used with:

      # Megabytes
      select sum(bytes)/1024/1024 size_in_mbytes from dba_segments;
      # Gigabytes
      select sum(bytes)/1024/1024/1024 size_in_gbytes from dba_segments;
      
* You can break this down by user by running:

      select owner, sum(bytes)/1024/1024 Size_MB from dba_segments
      group  by owner;

