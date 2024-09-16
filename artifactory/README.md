# JFrog Artifactory instructions

## How to move/rename an artifact with curl command

~~~
curl -uuser.name -XPOST "https://artifactory.domain.com/artifactory/api/copy/docker-local/imagename/latest?to=docker-local/imagename/latest-20240626"
~~~
