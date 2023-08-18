# miniDevOps: A DevOps Toolkit Operated within Docker

`miniDevOps` is a Docker image designed to provide a comprehensive set of DevOps tools and utilities, all within an Alpine Linux environment.

![Docker Pulls](https://img.shields.io/docker/pulls/brakmic/devops?style=plastic&logo=docker)

## Included DevOps Tools

* [kubectl](https://github.com/kubernetes/kubectl) (aliased with [`kubecolor`](https://github.com/kubecolor/kubecolor))
* [helm](https://github.com/helm/helm)
* [terraform](https://github.com/hashicorp/terraform)
* [kind](https://github.com/kubernetes-sigs/kind)
* [docker compose v2](https://github.com/docker/compose)
* [krew](https://github.com/kubernetes-sigs/krew) (kubectl's plugin manager)
* [kubens](https://github.com/ahmetb/kubectx#kubens)
* [kubectx](https://github.com/ahmetb/kubectx)
* [stern](howtos/stern.md)
* [skaffold](howtos/skaffold.md)
* [kubeseal](howtos/kubeseal.md)
* [kubelogin](https://github.com/Azure/kubelogin)
* [lazydocker](https://github.com/jesseduffield/lazydocker)

## Additional Packages

* bash (with completion functionality)
* nano (featuring syntax highlighting)
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
* apache2-ssl, accompanied by apache2-utils
## Setup

The [config.yml](./config.yml) file contains a suggested Kind cluster configuration. Feel free to modify it according to your specific needs.

To run the `miniDevOps` Docker image, execute the following command:

```bash
$ docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --network=host --workdir /root brakmic/devops:latest
```

The `/var/run/docker.sock` volume binding allows for communication with the host's Docker instance.

Once inside the container's shell, establish a new cluster using the command:

```bash
$ kind create cluster --name my-cluster
```

![mini_devops](./images/minidevops.png)

With this setup, you can now establish a new cluster and then copy the updated `.kube/config` into `/root/local`. This directory will persist its content, even after a Docker shutdown.

Additionally, a shell script titled `create_cluster.sh` is available. This script sets up the cluster and deploys the NGINX IngressController. Execute it with:

```bash
$ ./create_cluster.sh my-cluster
```

![create_cluster_script](./images/setup_cluster.png)

## Maintaining Persistent Kubernetes Clusters Across Docker Sessions

To retain your cluster between sessions, copy the current `.kube/config` to a local volume. Upon your next `miniDevOps` launch, replace the default `.kube/config` with the one you saved. Here's an example:

```bash
$ docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/root/local --network=host --workdir /root brakmic/devops:latest
```

This setup allows you to create a new cluster and then copy the updated `.kube/config` to `/root/local`. The contents of this directory will be preserved, even after the Docker system is shut down.

## Docker Image

The Docker image for `miniDevOps` is available at: [Docker Hub](https://hub.docker.com/r/brakmic/devops)

## Useful Commands and Examples

### kubectl

Check the status of all the nodes within namespace `dev` in your Kubernetes cluster:

```bash
$ kubectl get nodes -n dev
```

Learn more with the [Kubernetes Official Documentation](https://kubernetes.io/docs/tutorials/)

### helm

Install a package on your Kubernetes cluster. In this example, we are installing the stable release of Prometheus:

```bash
$ helm install prometheus stable/prometheus
```

Get started with the [Helm Official Documentation](https://helm.sh/docs/intro/using_helm/)

### terraform

Initialize a new Terraform working directory and apply the configurations:

```bash
$ terraform init
$ terraform apply
```

Explore more with the [Terraform Learn](https://learn.hashicorp.com/terraform)

### docker compose v2

Start all services defined in a `docker-compose.yml` file in detached mode:

```bash
$ docker compose up -d
```

Read more in the [Docker Compose Documentation](https://docs.docker.com/compose/migrate/)

### kind

Create a Kubernetes cluster with a specific name:

```bash
$ kind create cluster --name my-cluster
```

Learn how to get started with the [kind GitHub Quick Start Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)

### lazydocker

A simple terminal UI for both docker and docker-compose, to quickly manage projects with containers:

![lazydocker](./gifs/lazydocker.gif)

```bash
$ lazydocker
```

Check out the [lazydocker GitHub Repository](https://github.com/jesseduffield/lazydocker) for more information.

### kubeseal

Seal a Kubernetes secret using a public certificate:

```bash
$ kubeseal --cert=publicCert.pem --format=yaml < secret.yaml > sealedsecret.yaml
```

Read the [kubeseal GitHub Usage Guide](https://github.com/bitnami-labs/sealed-secrets#usage) to learn more.

### stern

Stream logs from multiple pods in real-time. For example, to stream logs from all pods with the label `app=myapp` in the `dev` namespace:

```bash
$ stern -n dev app=myapp
```

Learn more about Stern with its [GitHub Repository](https://github.com/stern/stern#usage)

### skaffold

Automate the workflow for building, pushing, and deploying applications in a Kubernetes environment. Here's how to start a development cycle on your local cluster:

```bash
$ skaffold dev
```

Get started with [Skaffold Documentation](https://skaffold.dev/docs/)

### kubelogin

Authenticate to a Kubernetes cluster using an OpenID Connect identity provider. For example:

```bash
$ kubelogin convert-kubeconfig -l azure
```

Learn more from [kubelogin GitHub Repository](https://github.com/Azure/kubelogin)

### krew

Krew is a plugin manager for `kubectl`. Use it to install and manage kubectl plugins. For example, to list all available plugins:

```bash
$ kubectl krew search
```

Explore [krew GitHub Repository](https://github.com/kubernetes-sigs/krew) to learn more.

### kubens

Switch between Kubernetes namespaces smoothly. For example, to switch to the `dev` namespace:

```bash
$ kubens dev
```

Check out [kubens GitHub Repository](https://github.com/ahmetb/kubectx#kubens) for more information.

### kubectx

Switch between Kubernetes contexts (clusters). For example, to switch to a context named `my-cluster`:

```bash
$ kubectx my-cluster
```

Learn more from the [kubectx GitHub Repository](https://github.com/ahmetb/kubectx)

## License

[MIT](LICENSE.md)
