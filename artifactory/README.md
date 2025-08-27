# JFrog Artifactory instructions

## How to move/rename an artifact with curl command

~~~sh
curl -uuser.name -XPOST "https://artifactory.domain.com/artifactory/api/copy/docker-local/imagename/latest?to=docker-local/imagename/latest-20240626"
~~~

## Clean up Artifactory

### Clean up a repository

Build process of an application has been:

1. There's a DEV repository where Maven artifacts are pushed during build. The versions of artifacts are incremented, so there are a lot of old artifacts which might or might not work.
2. Once application is in a state that it can be released, a new STABLE repository has been created.
3. All the artifacts have been copied from the DEV to STABLE because there's no intelligence to check which artifacts are useful.
4. Now building the application with the STABLE repositorys artifacts will produce same app everytime, but the unused artifacts take unnecessary storage space.

Clean-up process:

1. Install https://github.com/devopshq/artifactory-cleanup
1. As stated in the build process above, copy DEV repository to STABLE repository. After copy the artifacts are marked to have zero downloads in the new STABLE repository.
1. Build the application with the STABLE repository. Now the used articacts have a time stamp of download.
1. Create artifactory-cleanup.yaml

    ~~~yaml
    artifactory-cleanup:
      server: https://repo.example.com/artifactory
      # $VAR is auto populated from environment variables
      user: $ARTIFACTORY_USERNAME_CLEANUP
      password: $ARTIFACTORY_PASSWORD_CLEANUP
    
      policies:
        - name: Remove files without downloads
          rules:
            - rule: Repo
              name: repo-name-here
            - rule: DeleteWithoutDownloads
    ~~~

1. Run the command below to check what's going to be removed. `artifactory-cleanup` runs on DRY-MODE by default.

    ~~~sh
    artifactory-cleanup --config artifactory-cleanup.yaml
    ~~~

1. Run the command below to remove the unused artifacts.

    ~~~sh
    artifactory-cleanup --config artifactory-cleanup.yaml --destroy
    ~~~

1. Now there's a clean STABLE repository.
