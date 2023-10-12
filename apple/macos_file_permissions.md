~~~
ACL MANIPULATION OPTIONS
     ACLs are manipulated using extensions to the symbolic mode grammar.  Each file has one ACL, containing an ordered list
     of entries.  Each entry refers to a user or group, and grants or denies a set of permissions.  In cases where a user
     and a group exist with the same name, the user/group name can be prefixed with "user:" or "group:" in order to specify
     the type of name.

     If the user or group name contains spaces you can use ':' as the delimiter between name and permission.

     The following permissions are applicable to all filesystem objects:
           delete  Delete the item.  Deletion may be granted by either this permission on an object or the delete_child
                   right on the containing directory.
           readattr
                   Read an object's basic attributes.  This is implicitly granted if the object can be looked up and not
                   explicitly denied.
           writeattr
                   Write an object's basic attributes.
           readextattr
                   Read extended attributes.
           writeextattr
                   Write extended attributes.
           readsecurity
                   Read an object's extended security information (ACL).
           writesecurity
                   Write an object's security information (ownership, mode, ACL).
           chown   Change an object's ownership.

     The following permissions are applicable to directories:
           list    List entries.
           search  Look up files by name.
           add_file
                   Add a file.
           add_subdirectory
                   Add a subdirectory.
           delete_child
                   Delete a contained object.  See the file delete permission above.
                   
     The following permissions are applicable to non-directory filesystem objects:
           read    Open for reading.
           write   Open for writing.
           append  Open for writing, but in a fashion that only allows writes into areas of the file not previously written.
           execute
                   Execute the file as a script or program.
                   
     ACL inheritance is controlled with the following permissions words, which may only be applied to directories:
           file_inherit
                   Inherit to files.
           directory_inherit
                   Inherit to directories.
           limit_inherit
                   This flag is only relevant to entries inherited by subdirectories; it causes the directory_inherit flag
                   to be cleared in the entry that is inherited, preventing further nested subdirectories from also inherit-
                   ing the entry.
           only_inherit
                   The entry is inherited by created items but not considered when processing the ACL.

     The ACL manipulation options are as follows:

     +a      The +a mode parses a new ACL entry from the next argument on the commandline and inserts it into the canonical
             location in the ACL. If the supplied entry refers to an identity already listed, the two entries are combined.

https://discussions.apple.com/thread/4805409
sudo chmod -R +a "group:test_group allow delete,read,write,append,execute,list,search,add_file,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" test_permissions

https://apple.stackexchange.com/questions/31438/how-do-i-use-chmod-on-a-mac-to-make-new-files-inherit-parent-directory-permissio
chmod +a "group:examplegroup allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" /path/to/folder
~~~
