# Git and GitHub instructions

## Configurations

Set `git co` alias for `git checkout`
  * `git config --global alias.co checkout`

## Create a branch with Git and handle pull in GitHub

* Create a branch in Git

  ~~~sh
  git clone https://github.com/<org>/<repo>.git
  cd <repo>
  # Create and switch into a new branch
  git checkout -b new_branch
  # Check branches
  git branch -a
  # Make some changes
  vim test.txt
  git add test.txt
  git commit -m "Created test.txt"
  # Add upstream branch and push
  git push --set-upstream origin new_branch
  ~~~

* Handle pull request in GitHub
  1. In GitHub go to branches `https://github.com/<org>/<repo>/branches`
  1. Click "New pull request" in your branch
  1. Wait that somebody checks the pull request.
  1. Click Merge in GitHub.
  1. If you have build server and building is not automated, go there and build.

## Merge/rebase main to branch if required

~~~sh
git checkout main
git pull
git checkout new_branch
#git merge main # This creates a new dummy commit. It's better to rebase.
git rebase main
git push
~~~

## Stash and apply changes to another branch

If one edits accidentally wrong branch, one can stash and pop the changes to another branch.

  ~~~sh
  git stash
  git checkout <branch>
  git stash pop
  ~~~

## Remove undo latest local commit

* Source: https://stackoverflow.com/a/6866485/3498768
1. Option 1: git reset --hard

    You want to destroy the latest commit and also throw away any uncommitted changes. You do this:

    ~~~sh
    git reset --hard HEAD~1
    ~~~

1. Option 2: git reset

    Maybe the latest commit wasn't a disaster, but just a bit off. You want to undo the commit but keep your changes for a bit of editing before you do a better commit.

    ~~~sh
    git reset HEAD~1
    ~~~

1. Option 3: git reset --soft

    For the lightest touch, you can even undo your commit but leave your files and your index:

    ~~~sh
    git reset --soft HEAD~1
    ~~~

1. Option 4: you did git reset --hard and need to get that code back

    One more thing: Suppose you destroy a commit as in the first example, but then discover you needed it after all. Type this:

    ~~~sh
    git reflog
    ~~~

    and you'll see a list of (partial) commit shas (that is, hashes) that you've moved around in. Find the commit you destroyed, and do this:

    ~~~sh
    git checkout -b someNewBranchName shaYouDestroyed
    ~~~

## Squash commits into one

* Source https://stackoverflow.com/a/5201642/3498768

    ~~~sh
    # Check commits and messages
    git log
    
    # Undo 3 latest commits (4th latest shows with "git log" after this command)
    git reset --soft HEAD~3
    
    # Commit again with a new message
    git commit -m "New stuff"
    
    # Push into remote
    git push --force origin myBranch
    ~~~

* If one is searching for the commit number to squash, one can search commit hash with the one-liner below.

    ~~~sh
    hash="d0fb5581dfb73a502f2a13da1d7bb5a2f41ee974"; i=0; \
      while [ $(git rev-parse @~$i) != "$hash" ]; \
      do echo "Not " $(( i++ )); done; \
      echo "The matching commit is $(( i++ )). Reset with $i".
    ~~~

    When the matching commit is for example 21, then the reset command needs to have number 22, like `git reset --soft HEAD~22`, because the latest commit number is 0 and not 1.
