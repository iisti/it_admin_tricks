# General tips for Docker

## Run multiple commands via Docker container

~~~
docker run -t --rm --name "node-alpine" \
    "node:20.13.1-alpine" \
    /bin/sh -c \
    "echo example && echo example2"
~~~


## Check docker disk usage
* Disk usage
    ~~~
    docker system df
    ~~~
* `--verbose` argument gives more information
    ~~~
    docker system df --verbose
    ~~~

## Rebuild image and run scripts easily
* Rebuild and run image easily
    ~~~
    cont_name="container007"
    cont_path="/home/iisti/container007"
    dockerfile="/home/iisti/container007/Dockerfile.ver01"
    docker stop "$cont_name" && \
        docker rm "$cont_name" ; \
        docker build -f "$dockerfile" -t "$cont_name":latest "$cont_path"/. && \
        docker run -dit --name "$cont_name" "$cont_name":latest
    ~~~
* Copy scripts into container, no need to rebuild all the time. This step can be also a CI/CD step.
    * Notice that we're using the same path and name variables as above.
    ~~~
    docker cp "$cont_path" "$cont_name":/
    ~~~
* Bash into the container, so you can run the scripts.
    ~~~
    docker exec -it "$cont_name" bash
    ~~~
## Reverse engineer a Docker image and create a Dockerfile
* This will not create a Dockerfile which could be directly build with `docker build`. The output will be a reference to build a Dockerfile.
    ~~~
    dfimage -sV=1.36 <URL_TO_DOCKER_REGISTRY/PATH/IMAGE:TAG > dfimage_IMAGE.txt
    ~~~

## Remove multiple containers and images easily
In this example there are containers and images which have `end-to-end` in some value (keys: Names or Repositories).

Notice that this example requires `jq` to be installed.

### Remove containers
1. List the containers
    ~~~
    docker container list -a --format '{{json .}}' |
      jq -r '. | select ((.Names | contains("end-to-end")) )'
    ~~~
    * Output should be something like this:
        ~~~
        {
          "Command": "\"bash /on-prem-insta…\"",
          "CreatedAt": "2023-09-22 07:00:31 +0000 UTC",
          "ID": "1d179fc37987",
          "Image": "service-image__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Labels": "",
          "LocalVolumes": "0",
          "Mounts": "",
          "Names": "service__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Networks": "e52a4__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Ports": "",
          "RunningFor": "4 days ago",
          "Size": "1.6GB (virtual 4.44GB)",
          "State": "exited",
          "Status": "Exited (137) 4 days ago"
        }
        {
          "Command": "\"bash /on-prem-insta…\"",
          "CreatedAt": "2023-09-22 06:59:24 +0000 UTC",
          "ID": "098860d907d5",
          "Image": "conversion-service-image__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Labels": "",
          "LocalVolumes": "0",
          "Mounts": "",
          "Names": "conversion-service__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Networks": "e52a4__jenkins-end-to-end-tests-conversion-load-tests-oracle-5",
          "Ports": "",
          "RunningFor": "4 days ago",
          "Size": "955MB (virtual 3.03GB)",
          "State": "exited",
          "Status": "Exited (137) 4 days ago"
        }
        ~~~ 
1. Select only IDs
    ~~~
    docker container list -a --format '{{json .}}' | jq -r '. | select ((.Names | contains("end-to-end")) ) | .ID'
    ~~~
    * Output should be something like this
      ~~~
      1d179fc37987
      098860d907d5
      ~~~
1. Remove the containers
    ~~~
    while read i; do docker container rm $i; done <<< $(docker container list -a --format '{{json .}}' | jq -r '. | select ((.Names | contains("end-to-end")) ) | .ID')
    ~~~

### Remove images
This works the same as removing containers expect `select` statement needs to be different and commands need to be `image` not `container`.
1. Select only IDs
    ~~~
    docker image list --format '{{json .}}' | jq -r '. | select ((.Repository | contains("end-to-end")) ) | .ID'
    ~~~
1. Remove the images
    ~~~
    while read i; do docker image rm $i; done <<< $(docker image list --format '{{json .}}' | jq -r '. | select ((.Repository | contains("end-to-end")) ) | .ID')
    ~~~
1. You might need to run the below to remove build cache.
    ~~~
    docker builder prune
    ~~~
