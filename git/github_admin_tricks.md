# Instructions and tricks for GitHub

## How to retrieve organisation members
* https://github.com/iisti/github_get_org_users


## How to retrieve all users in project
* Create a personal access token
  * Select: admin:org -> read:org
    * Read org and team membership, read org projects
  * Source: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
* Run in shell to retrieve users:
  * Source: https://docs.github.com/en/rest/reference/orgs#list-organization-members
  * Source: https://stackoverflow.com/a/50246880/3498768
  ~~~
  # This shows only first 100 members!
  # Change organisation and token
  my_token="1234xxx"; \
  my_organisation="my_organization"; \
  curl \
    -H "Authorization: token ${my_token}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/"$my_organisation"/members?per_page=100 \
    | grep login >> github_"$my_organisation"_members.txt
  ~~~

## Check information of one user
* Run to check information of one user:
~~~
my_token="access_token"; \
get_user="username"; \
curl \
    -H "Authorization: token ${my_token}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/users/"$get_user"
~~~

## Remove history from repository
***Attention, this removes the configuration of the repository!***

1. Remove all history
    ~~~
    cd myrepo
    rm -rf .git
    ~~~
1. Inititialize a new repository
    ~~~
    git init
    git add .
    git commit -m "Removed history"
    ~~~
1. Push to remote, when using GitHub rename *master* to *main*
    ~~~
    git remote add origin github.com:username/myrepo.git
    git branch -m master main
    git push -u --force origin main
    ~~~
