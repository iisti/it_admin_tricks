# Java tricks

## Maven

### Maven Download Dependencies/Artifacts

1. Prerequisite: install Java and Maven
1. Create a temp folder

    ~~~sh
    tmp=$(mktemp -d)
    ~~~

1. Create an array of artifacts that should be downloaded

    ~~~sh
    # syntax: group-id:artifact-id:version
    dependencies="commons-io:commons-io:2.14.0
    org.postgresql:postgresql:42.3.9"
    
    readarray -t arr_artifacts <<<"$dependencies"
    ~~~

1. One can print the created array

    ~~~sh
    for (( i=0; i<${#arr_artifacts[@]}; i++ ))
    do
        echo "$i: ${arr_artifacts[$i]}"
    done
    ~~~

1. Download the artifacts to the temp folder

    ~~~sh
    for (( i=0; i<${#arr_artifacts[@]}; i++ ))
    do
        mvn dependency:get \
          -DremoteRepositories=https://mvnrepository.com/artifact \
          -Dmaven.repo.local="$tmp" \
          -Dartifact="${arr_artifacts[$i]}"
    done
    ~~~
