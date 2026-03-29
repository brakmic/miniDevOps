param (
    [Parameter(Position = 0)]
    [string]$ClusterName = "hbr-cluster",

    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host "Usage: create_cluster.ps1 [-ClusterName <name>] [-Help]"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  ClusterName   Name for the Kind cluster (default: hbr-cluster)"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help         Display this help message and exit"
    exit 0
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$kindConfig = Join-Path $scriptDir "config.yml"

if (-not (Test-Path $kindConfig)) {
    Write-Error "Configuration file '$kindConfig' not found."
    exit 1
}

Write-Host "Cluster Name: $ClusterName"
Write-Host "Kind Config Path: $kindConfig"

# Check if the cluster already exists
$existingClusters = kind get clusters 2>&1
if ($existingClusters -match "^\s*$ClusterName\s*$") {
    $response = Read-Host "Kind cluster '$ClusterName' already exists. Delete and recreate? (y/N)"
    if ($response -match '^[yY]') {
        kind delete cluster --name $ClusterName
        Write-Host "Existing Kind cluster '$ClusterName' deleted."
    }
    else {
        Write-Host "Exiting without making changes."
        exit 0
    }
}

# Create Kind cluster
kind create cluster --name $ClusterName --config $kindConfig
Write-Host "Kind cluster '$ClusterName' created successfully."
Write-Host " --- "

# Deploy NGINX Ingress Controller
Write-Host " --- Deploying NGINX IngressController ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
Write-Host "NGINX Ingress Controller deployment initiated."

Write-Host " --- Waiting for deployment to complete ---"
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
Write-Host " --- k8s is now ready ---"
