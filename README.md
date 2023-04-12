## miniDevOps - a toolbox running in Docker (Alpine Linux)

It contains the following DevOps tools:

* kubectl
* helm
* terraform
* kind
 
Additionally, it provides the following packages:

* bash + completion
* nano + syntax hightlighting
* vim
* git
* gcc
* make
* zip
* lynx
* curl
* wget
* apache2-ssl + apache2-utils

The config.yml contains a recommended Kind cluster configuration. Feel free to adapt to your needs. 

To run the image execute the following command (adapt the volume bindings accordingly).

```bash
$ docker run --rm -it -v {$PWD}:/root -v {$HOME/.kube}:/root/.kube --rm --network=host --workdir /work devops
``` 

The Docker image is available at: https://hub.docker.com/repository/docker/brakmic/devops

# LICENSE
[MIT](LICENSE.md)

