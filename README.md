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

To run the image execute the following command. The /var/run/docker.sock volume binding makes it possible to communicate with host's Docker instance. 

```bash
$ docker run --rm -it --rm -v /var/run/docker.sock:/var/run/docker.sock --network=host --workdir /root devops
```
Now try to create a new cluster by using Kind as shown in the screenshot below.

![mini_devops](./images/minidevops.png)

There is also a shell script that takes care of cluster creation and NGINX-Ingress deployment.

![create_cluster_script](./images/setup_cluster.png)

The Docker image is available at: https://hub.docker.com/repository/docker/brakmic/devops

# LICENSE
[MIT](LICENSE.md)

