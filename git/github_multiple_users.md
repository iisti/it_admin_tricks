# How to setup multiple GitHub users for same machine

* There are 2 users
  * Personal user
  * Work user

1. Create config directories for both users
    ~~~
    cd ~
    mkdir .git-personal
    mkdir .git-work
    ~~~
1. Create .gitconfig in the user directories
    * git-personal/.gitconfig
      ~~~
      [user]
          email = example@mail.com
          name = Your Name
      ~~~
1. Create main .gitconfig file
    ~~~
    # ~/.gitconfig

    [includeIf "gitdir:~/git-personal/"]
    path = ~/git-personal/.gitconfig

    [includeIf "gitdir:~/git-work/"]
    path = ~/git-work/.gitconfig
    ~~~
1. To save passwords or tokens, you can use Git Credential Store
    * More information about Git Credential Store https://git-scm.com/docs/git-credential-store 
    * Git Credential Store can manage only one user. To workaround that one option is to use option "credential.useHttpPath". This option enables that credentials are saved per URL and not by user.
        ~~~
        git config --global credential.useHttpPath true
        ~~~
    * Enable credential store
        ~~~
        git config credential.helper store
        ~~~
    * One can now clone or run other commmand. The first time username/token is asked, but in future they're not.
        ~~~
        git clone https://github.com/username/repo.git
        ~~~
    * Now the credentials are saved in format below in file `~/.git-credentials`
        ~~~
        git:https://PersonalAccessToken@github.com/YourUsername/YourRepo1.git
        git:https://PersonalAccessToken2@github.com/YourUsername2/YourRepo2.git
        git:https://PersonalAccessToken@github.com/YourUsername/YourRepo3.git
        ~~~
1. Check config
    ~~~
    git config --list
    ~~~
1. User details can be configured by repository:
    ~~~
    git config user.name 'Your Name'
    git config user.email 'name@example.com'
    ~~~
