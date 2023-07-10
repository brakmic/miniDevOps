## miniDevOps - a DevOps toolbox running in Docker (Alpine Linux)

It contains the following DevOps tools:

* kubectl (aliased to `kubecolor`)
* helm
* terraform
* kind
* docker-compose
* krew (kubectl's plugin manager)
* kubens
* kubectx
* [stern](howtos/stern.md)
* skaffold
* [kubeseal](howtos/kubeseal.md)
* kubelogin
 
Additionally, it provides the following packages:

* bash + completion
* nano + syntax hightlighting
* vim
* git
* gcc
* go
* python3
* make
* zip
* lynx
* curl
* wget
* jq
* ncurses
* apache2-ssl + apache2-utils

## Setup

The `config.yml` contains a recommended Kind cluster configuration. Feel free to adapt to your needs. 

To run the image execute the following command. The `/var/run/docker.sock` volume binding makes it possible to communicate with host's Docker instance.

```bash
$ docker run --rm -it --rm -v /var/run/docker.sock:/var/run/docker.sock --network=host --workdir /root brakmic/devops:latest
```
Now try to create a new cluster by using Kind as shown in the screenshot below.

[![mini_devops](./images/minidevops.png)](https://github.com/brakmic/miniDevOps/blob/dc198a8a54af670753833408d7263432a31a40cf/images/minidevops.png)

There is also a shell script, `create_cluster.sh`, that takes care of cluster creation and NGINX-Ingress deployment. Just enter the cluster name as its only parameter and the rest will be done automatically.

[![create_cluster_script](./images/setup_cluster.png)](https://github.com/brakmic/miniDevOps/blob/dc198a8a54af670753833408d7263432a31a40cf/images/setup_cluster.png)

## Keeping clusters between docker sessions

If you want to keep the cluster you created during a session, simply copy the current `.kube/config` to a local volume. Next time you fire up miniDevOps just overwrite the default `.kube/config` with yours. For example:

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/root/local --rm --network=host --workdir /root brakmic/devops:latest
```

Now you can create a new cluster and then copy the updated `.kube/config` to `/root/local` whose contents will be available after docker shutdown.

The Docker image is available at: https://hub.docker.com/r/brakmic/devops

# LICENSE
[MIT](LICENSE.md)

