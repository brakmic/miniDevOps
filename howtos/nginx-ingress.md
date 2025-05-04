# Installing NGINX Ingress Controller v1.22.2

This guide explains how to install the open-source NGINX Ingress Controller version 1.22.2 on a Kubernetes cluster.

## Prerequisites

- A functioning Kubernetes cluster
- `kubectl` installed and configured to connect to your cluster
- Cluster admin permissions

## Installation Steps

### Step 1: Create the namespace

```bash
kubectl create namespace ingress-nginx
```

### Step 2: Install NGINX Ingress Controller v1.22.2

For most Kubernetes environments (cloud providers):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.2/deploy/static/provider/cloud/deploy.yaml
```

For bare-metal environments:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.2/deploy/static/provider/baremetal/deploy.yaml
```

### Step 3: Verify the installation

Check that the controller pods are running:

```bash
kubectl get pods -n ingress-nginx
```

The output should show the controller pod with status `Running`:

```
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-6b94c75499-7qctb   1/1     Running   0          30s
```

### Step 4: Verify the service

```bash
kubectl get service -n ingress-nginx
```

You should see the controller service:

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.100.10.100   <pending>     80:30950/TCP,443:31707/TCP   1m
ingress-nginx-controller-admission   ClusterIP      10.100.11.101   <none>        443/TCP                      1m
```

## Basic Usage Example

Create an Ingress resource (save as `example-ingress.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

Apply the Ingress resource:

```bash
kubectl apply -f example-ingress.yaml
```

## Troubleshooting

If you encounter issues, check the controller logs:

```bash
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

For additional configuration options and troubleshooting, refer to the [official documentation](https://kubernetes.github.io/ingress-nginx/).
