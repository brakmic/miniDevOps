# miniDevOps: A DevOps Toolkit Operated within Docker

`miniDevOps` is a Docker image designed to provide a comprehensive set of DevOps tools and utilities, all within an Alpine Linux environment.

![Docker Pulls](https://badgen.net/docker/pulls/brakmic/devops?icon=docker)
[![Docker Image Size](https://badgen.net/docker/size/brakmic/devops?icon=docker&label=image%20size)](https://hub.docker.com/r/brakmic/devops/)

## Included DevOps Tools

* [kubectl](https://github.com/kubernetes/kubectl) (aliased with [`kubecolor`](https://github.com/kubecolor/kubecolor))
* [helm](https://github.com/helm/helm)
* [terraform](https://github.com/hashicorp/terraform)
* [flux](https://fluxcd.io)
* [operator-sdk](https://sdk.operatorframework.io/)
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
* [usql](https://github.com/xo/usql)

## Additional Packages

* bash (with completion functionality)
* nano (featuring syntax highlighting)
* vim
* git
* gcc
* go
* python3
* pip3
* make
* zip
* lynx
* curl
* wget
* jq
* ncurses
* apache2-ssl, accompanied by apache2-utils

## Python and Pipenv Development Environment

`miniDevOps` includes Python and Pipenv, making it a convenient environment for Python development. Whether you're creating scripts to manage your infrastructure or developing full-fledged applications, this Docker image is equipped to handle your Python needs.

* **Python**: A versatile and widely-used programming language. The image includes Python 3, allowing you to run and develop Python applications.

* **Pipenv**: The officially recommended Python packaging tool from Python.org. It automatically creates and manages a virtual environment for your projects, as well as adds/removes packages from your `Pipfile` as you install/uninstall packages. It also generates the `Pipfile.lock`, which is used to produce deterministic builds.

Example usage:
```bash
$ pipenv install requests
$ pipenv run python my_script.py
```

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

Additionally, a shell script titled `create_cluster.sh` is available. This script sets up the cluster and deploys the NGINX IngressController.

Execute it with:

```bash
$ ./create_cluster.sh my-cluster
```

![create_cluster_script](./images/setup_cluster.png)

## For Windows Users:
If you are running Docker on Windows, an alternative PowerShell script is available. This script provides a similar functionality as the bash script for setting up the cluster and deploying the NGINX IngressController. You can run this script in PowerShell with:

```powershell
.\create_cluster.ps1 -CLUSTERNAME MyClusterName
```

Please ensure that both kind and kubectl command-line tools are installed and available in your PATH when you run this PowerShell script.

## Maintaining Persistent Kubernetes Clusters Across Docker Sessions

To retain your cluster between sessions, copy the current `.kube/config` to a local volume. Upon your next `miniDevOps` launch, replace the default `.kube/config` with the one you saved. Here's an example:

```bash
$ docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/root/local --network=host --workdir /root brakmic/devops:latest
```

This setup allows you to create a new cluster and then copy the updated `.kube/config` to `/root/local`. The contents of this directory will be preserved, even after the Docker system is shut down.

## Docker Image

The Docker image for `miniDevOps` is available at: [Docker Hub](https://hub.docker.com/r/brakmic/devops)

## HOWTOs

The following guides provide detailed instructions on how to use some of the included DevOps tools in the `miniDevOps` Docker image:

1. **kubeseal**: Learn how to [seal a secret](https://github.com/brakmic/miniDevOps/blob/main/howtos/kubeseal.md) in Kubernetes. 
   
2. **skaffold**: Understand the [automated workflow](https://github.com/brakmic/miniDevOps/blob/main/howtos/skaffold.md) for building, pushing, and deploying applications with Skaffold.  
   
3. **stern**: Get to know how to [stream logs](https://github.com/brakmic/miniDevOps/blob/main/howtos/stern.md) from multiple pods in real-time.


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

### operator-sdk

[Operator SDK](https://sdk.operatorframework.io/) is a toolkit to accelerate building Kubernetes native applications. With the Operator SDK, developers can build, test, and deploy Operators - applications that can manage and automate complex systems within a Kubernetes cluster. The SDK provides high-level APIs, useful abstractions, and project scaffolding that facilitates the fast development of Operators, without requiring deep Kubernetes API knowledge. The Operator SDK supports various operator types including Helm, Ansible, and Go, allowing developers to choose the best tool for their use case.

Example usage:
```bash
# Create a new operator project
$ operator-sdk init --domain=example.com --repo=github.com/example-inc/memcached-operator

# Create a new API for the custom resource
$ operator-sdk create api --group cache --version v1alpha1 --kind Memcached --resource --controller

# Build and push the operator image
$ make docker-build docker-push IMG=<some-registry>/memcached-operator:v0.0.1

# Deploy the operator to a cluster
$ make install
$ make deploy IMG=<some-registry>/memcached-operator:v0.0.1
```

This sets up the basic scaffolding for your operator project, creates the necessary CRDs (Custom Resource Definitions), and allows you to push your operator to a container registry and deploy it to a Kubernetes cluster. From here, you can define your operator’s logic and specify how it should manage the application’s lifecycle.

### flux

[Flux](https://fluxcd.io) is a toolset for keeping Kubernetes clusters in sync with infrastructure-as-code systems, like Git repositories, and automating updates to configuration and images. It uses a pull-based approach to continuously deploy and monitor applications. With Flux, you can ensure that your cluster's state matches the versioned sources, allowing for GitOps practices in your workflow.

Flux supports multi-tenancy and scales to multiple clusters, ensuring declarative infrastructure for both small-scale applications and large-scale operations. It comes with powerful features like automatic updates, policy-driven deployments, and integrations with prominent Kubernetes-native tools.

Example usage:
```bash
# Bootstrap Flux on your cluster
$ flux bootstrap github \
  --owner=<your-user> \
  --repository=<your-repository> \
  --branch=main \
  --path=./clusters/your-cluster \
  --personal

# Check components status
$ flux check

# Sync your cluster state with the Git repository
$ flux reconcile source git flux-system
```

With these commands, you've set up Flux to manage your Kubernetes cluster according to the infrastructure-as-code definitions in your Git repository. Flux will now automatically ensure that your cluster's state matches the configurations in the Git repository, and any change to the repository will be promptly applied to the cluster.

Dive deeper with the [Flux Official Documentation](https://fluxcd.io/docs/introduction/).

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

### uSQL

uSQL is a modern query language and execution engine that facilitates data querying across different platforms and data sources. It provides a unified SQL interface for various databases and file formats.

#### Features

* **Unified Querying**: Write SQL queries that work across different databases and file formats.
* **Optimization Engine**: Automatic optimization for complex queries to ensure efficient execution.
* **Extensibility**: Easy to extend with custom functions and data sources.

uSQL supports a wide range of databases and file formats including MySQL, PostgreSQL, SQLite, CSV, Excel, and more.
#### Usage

You can execute queries using the uSQL command-line interface:

```sql
usql "SELECT * FROM file.csv WHERE column > 10"
```

For more detailed information, visit the [official documentation](https://usql.io/docs).


## License

[MIT](LICENSE.md)
