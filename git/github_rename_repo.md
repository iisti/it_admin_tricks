# How to rename a repository in GitHub

* Source: https://stackoverflow.com/questions/2041993/how-do-i-rename-a-git-repository
1. (Optional) Edit displayed name in .git/description
    * The description file doesn't actually necessarily have anything necessary information. It's showed in some services, but not every service uses it.
1. Rename the GitHub repository in GitHub repository settings.
1. Rename the local Git repository root directory.
1. After renaming repository in GitHub, check the remote origin URL and change it in the local repository.
    ~~~
    # Show current
    git config --get remote.origin.url
    # More information about the origin
    git remote -v show origin
    # Show new one
    git remote set-url origin https://new_url
    ~~~
