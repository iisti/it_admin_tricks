# General tips for ESXi usage.

## Print folder structure
* There's no `tree` command in ESXi. One can use the oneliner below to print folder structure.
    * This doesn't print file, only folders!
    ~~~
    ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
    ~~~
    * https://access.redhat.com/solutions/53656
