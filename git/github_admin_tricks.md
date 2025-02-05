# Instructions and tricks for GitHub

## Checkout only one sub-directory of a repository

`svn export` doesn't work anymore with GitHub since 8.1.2024, source <https://github.blog/news-insights/product-news/sunsetting-subversion-support/>

### One can use sparse-checkout

~~~sh
git clone --filter=blob:none --sparse   git@github.com:iisti/MY-REPO.git
cd MY-REPO
git sparse-checkout add MY-SUBDIRECTORY-TO-BE-CLONED
cd MY-SUBDIRECTORY-TO-BE-CLONED
~~~

`git pull` should work normally.

* Source <https://stackoverflow.com/a/73254328/3498768>

## How to retrieve organisation members

* <https://github.com/iisti/github_get_org_users>

## How to retrieve all users in project

* Create a personal access token
  * Select: admin:org -> read:org
    * Read org and team membership, read org projects
  * Source: <https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token>
* Run in shell to retrieve users:
  * Source: <https://docs.github.com/en/rest/reference/orgs#list-organization-members>
  * Source: <https://stackoverflow.com/a/50246880/3498768>

  ~~~sh
  # Create file with name "token" and put the access token into the file, so the content should be something like:
  # ghp_cxzFBJyyyy70m7mSeUsaxxxxxxxxxxxxxxxx
  # This shows only first 100 members!
  # Change organisation
  my_organisation="my_organization"; \
  my_token=$(head -n 1 token); \
  curl \
    -H "Authorization: token ${my_token}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/"$my_organisation"/members?per_page=100 \
    | grep login >> github_"$my_organisation"_members_$(date +"%Y-%m-%d_%H-%M").txt
  ~~~

## Check information of one user

* Run to check information of one user:

~~~sh
my_token="access_token"; \
get_user="username"; \
curl \
    -H "Authorization: token ${my_token}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/users/"$get_user"
~~~

## Remove a file and its commit history from a repository

***Attention, make a backup copy of the repository before doing this!***

* Good source: <https://rtyley.github.io/bfg-repo-cleaner/>

1. Install BFG or download BFG JAR
    * As JAR BFG can be run like:
        * java -jar bfg.jar --strip-blobs-bigger-than 100M some-big-repo.git
1. cd into a repo

    ~~~sh
    cd <git_repo>
    ~~~

1. Backup the file which is going to be removed. If you want to remove just some sensitive data, make a copy of the file somewhere out of the Git repo and remove sensitive data.
1. Remove the file from Git and make a commit.

    ~~~sh
    git rm file_which_had_security_issues
    git commit -m "Removed files with security issues."
    ~~~  

1. Remove the file with bfg

   ~~~sh
   bfg --delete-files file_which_had_security_issues
   ~~~

   * Use flag --no-blob-protection to turn off protection.

     ~~~sh
     bfg --no-blob-protection --delete-files file_which_had_security_issues
     ~~~

1. Run the line below is bfg asks for it.

   ~~~sh
   git reflog expire --expire=now --all && git gc --prune=now --aggressive
   ~~~

1. Force push

   ~~~sh
   git push --force
   ~~~

1. If a new file without sensitive data was created, copy the file back into repository and make a commit.

## Remove all history from repository

***Attention, this removes the configuration of the repository!***

1. Remove all history

    ~~~sh
    cd myrepo
    rm -rf .git
    ~~~

1. Inititialize a new repository

    ~~~sh
    git init
    git add .
    git commit -m "Removed history"
    ~~~

1. Push to remote, when using GitHub rename *master* to *main*

    ~~~sh
    git remote add origin https://github.com:/username/myrepo.git
    git branch -m master main
    git push -u --force origin main
    ~~~

## List all repositories in an organization

* Install GitHub CLI <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>
* List repos in default mode. Use -L to indicate how many repos you want to list, default is 30.

  ~~~sh
  gh repo list <org_name> -L 150
  ~~~

* List only the names of the repos.

  ~~~sh
  gh repo list <org_name> -L 150 --json name | jq -r .[].name | sort
  ~~~
