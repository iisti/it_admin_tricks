# Rocky / CentOS Linux Instructions

## How to lock yum / dnf package versions, so they don't update

`versionlock` is comparable to `apt-mark`.

~~~sh
# Install versionlock package
sudo dnf install dnf-plugins-core

# Lock a specific package version
sudo dnf versionlock add httpd

# To view all locked packages
sudo dnf versionlock list

# To remove a package from the version lock
sudo dnf versionlock delete httpd
~~~

## APT vs DNF

* <https://docs.fedoraproject.org/en-US/quick-docs/dnf-vs-apt/>
