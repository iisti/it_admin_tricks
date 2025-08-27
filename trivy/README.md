# Aquasecurity / Trivy instructions

https://github.com/aquasecurity/trivy

## Scan Dockerimage

The following command will check for vulnerabilities and produces sarif file that can be opened with i.e. VisualStudio Code. 

~~~sh
img="image-name"; \
  trivy image \
    --dependency-tree \
    --format sarif \
    --output ./"$img"_$(date +"%Y-%m-%d_%H-%M").sarif \
    docker.registry.com/path/"$img":latest
~~~
