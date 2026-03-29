# miniDevOps

A Docker image that bundles 20+ Kubernetes and infrastructure tools on Debian Linux. Pull it, start a container, and you have a working cluster in minutes.

![shell_welcome_msg](./gifs/miniDevOps.gif)

![Docker Pulls](https://badgen.net/docker/pulls/brakmic/devops?icon=docker)
[![Docker Image Size](https://badgen.net/docker/size/brakmic/devops?icon=docker&label=image%20size)](https://hub.docker.com/r/brakmic/devops/)

## Quick Start

```bash
docker pull brakmic/devops:latest
```

**Linux / macOS:**

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${PWD}:/home/minidevops/local \
  --network=host \
  brakmic/devops:latest
```

**Windows (PowerShell):**

```powershell
docker run --rm -it `
  -v //var/run/docker.sock:/var/run/docker.sock `
  -v ${PWD}:/home/minidevops/local `
  --network=host `
  brakmic/devops:latest
```

### Windows: Cgroup v2 Requirement

Kubernetes 1.35+ requires cgroup v2. Docker Desktop on Windows must use the WSL 2 backend with the unified cgroup hierarchy enabled. Without this, Kind clusters fail during kubelet startup with a health check timeout.

1. Enable the WSL 2 engine in Docker Desktop under Settings > General.
2. Create or edit `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
kernelCommandLine = cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
```

3. Restart WSL and Docker Desktop:

```powershell
wsl --shutdown
```

Verify the change by running `docker info --format '{{.CgroupVersion}}'`. The output should be `2`.

Once inside the container, create a cluster:

```bash
./create_cluster.sh my-cluster
```

The socket mount lets the container talk to the host Docker daemon. The local volume mount at `/home/minidevops/local` persists files across container restarts. The cluster script creates a Kind cluster and deploys the NGINX Ingress Controller.

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| [kubectl](https://github.com/kubernetes/kubectl) | latest stable | Kubernetes CLI, aliased to [kubecolor](https://github.com/kubecolor/kubecolor) |
| [helm](https://github.com/helm/helm) | 4.1.3 | Kubernetes package manager |
| [terraform](https://github.com/hashicorp/terraform) | 1.14.8 | Infrastructure as code |
| [kind](https://github.com/kubernetes-sigs/kind) | 0.31.0 | Local Kubernetes clusters in Docker |
| [k9s](https://k9scli.io/) | 0.50.18 | Terminal UI for Kubernetes |
| [stern](https://github.com/stern/stern) | 1.33.1 | Multi-pod log tailing |
| [kubecolor](https://github.com/kubecolor/kubecolor) | 0.5.3 | Colorized kubectl output |
| [skaffold](https://skaffold.dev/) | 2.18.2 | Continuous development for Kubernetes |
| [flux](https://fluxcd.io) | 2.8.3 | GitOps toolkit |
| [kubeseal](https://github.com/bitnami-labs/sealed-secrets) | 0.36.1 | Encrypt secrets for Git storage |
| [operator-sdk](https://sdk.operatorframework.io/) | 1.42.2 | Build Kubernetes operators |
| [kubelogin](https://github.com/Azure/kubelogin) | 0.2.16 | Azure AD authentication for clusters |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | 0.25.0 | Terminal UI for Docker |
| [popeye](https://popeyecli.io/) | 0.22.1 | Cluster sanitizer and linter |
| [krew](https://github.com/kubernetes-sigs/krew) | 0.5.0 | kubectl plugin manager |
| [kubectx](https://github.com/ahmetb/kubectx) | 0.11.0 | Switch between clusters |
| [kubens](https://github.com/ahmetb/kubectx) | 0.11.0 | Switch between namespaces |
| [usql](https://github.com/xo/usql) | 0.21.4 | Universal SQL client |
| [docker compose](https://github.com/docker/compose) | v2 | Multi-container orchestration |

## Additional Packages

The image includes bash with completions, nano with syntax highlighting, vim, git, gcc, make, python3, pip3, pipenv, curl, htop, tree, openssl, iputils-ping, dnsutils, and hping3.

Python 3 and Pipenv are pre-configured with a virtual environment. Run `pipenv install <package>` to add dependencies and `pipenv run python my_script.py` to execute scripts.

## Setup

The [config.yml](./config.yml) file contains a Kind cluster configuration you can adjust. The included `create_cluster.sh` script reads this config, creates the cluster, and deploys NGINX Ingress.

```bash
./create_cluster.sh my-cluster
```

![mini_devops](./images/minidevops.png)

On Windows, use the PowerShell equivalent:

```powershell
.\create_cluster.ps1 -ClusterName MyClusterName
```

![create_cluster_script](./images/setup_cluster.png)

### Persisting Cluster State

To keep your cluster across container restarts, copy `.kube/config` to the local volume before exiting:

```bash
cp ~/.kube/config ~/local/kubeconfig-backup
```

On the next run, restore it:

```bash
cp ~/local/kubeconfig-backup ~/.kube/config
```

## Docker Image

Available on [Docker Hub](https://hub.docker.com/r/brakmic/devops).

## HOWTOs

- [Sealing secrets with kubeseal](./howtos/kubeseal.md)
- [Automated builds with Skaffold](./howtos/skaffold.md)
- [Streaming logs with Stern](./howtos/stern.md)
- [Installing NGINX Ingress Controller](./howtos/nginx-ingress.md)

## Command Reference

### kubectl

```bash
kubectl get pods -n kube-system
```

[Kubernetes docs](https://kubernetes.io/docs/tutorials/)

### helm

```bash
helm install prometheus prometheus-community/prometheus
```

[Helm docs](https://helm.sh/docs/intro/using_helm/)

### terraform

```bash
terraform init && terraform apply
```

[Terraform docs](https://learn.hashicorp.com/terraform)

### operator-sdk

```bash
operator-sdk init --domain=example.com --repo=github.com/example-inc/my-operator
operator-sdk create api --group cache --version v1alpha1 --kind Memcached --resource --controller
```

[Operator SDK docs](https://sdk.operatorframework.io/)

### flux

```bash
flux bootstrap github \
  --owner=<your-user> \
  --repository=<your-repo> \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

[Flux docs](https://fluxcd.io/docs/)

### docker compose

```bash
docker compose up -d
```

[Compose docs](https://docs.docker.com/compose/)

### kind

```bash
kind create cluster --name my-cluster
```

[kind docs](https://kind.sigs.k8s.io/docs/user/quick-start/)

### lazydocker

![lazydocker](./gifs/lazydocker.gif)

```bash
lazydocker
```

[lazydocker repo](https://github.com/jesseduffield/lazydocker)

### popeye

```bash
popeye -n kube-system -o yaml
```

[Popeye docs](https://popeyecli.io/)

### kubeseal

```bash
kubeseal --cert=publicCert.pem --format=yaml < secret.yaml > sealedsecret.yaml
```

[kubeseal docs](https://github.com/bitnami-labs/sealed-secrets#usage)

### stern

```bash
stern -n dev app=myapp
```

[stern repo](https://github.com/stern/stern#usage)

### skaffold

```bash
skaffold dev
```

[Skaffold docs](https://skaffold.dev/docs/)

### kubelogin

```bash
kubelogin convert-kubeconfig -l azure
```

[kubelogin repo](https://github.com/Azure/kubelogin)

### krew

```bash
kubectl krew install ctx
```

[krew repo](https://github.com/kubernetes-sigs/krew)

### kubectx / kubens

```bash
kubectx my-cluster
kubens dev
```

[kubectx repo](https://github.com/ahmetb/kubectx)

### usql

```bash
usql postgres://user:pass@localhost/mydb -c "SELECT count(*) FROM orders"
```

[usql repo](https://github.com/xo/usql)

## License

[MIT](./LICENSE)
