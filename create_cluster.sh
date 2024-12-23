#!/usr/bin/env bash

# Absolute paths to commands
KIND_CMD="kind"
KUBECTL_CMD="kubectl"

# Function to display help
usage() {
    echo "Usage: $0 [OPTIONS] [CLUSTERNAME]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Display this help message and exit"
    echo ""
    echo "Arguments:"
    echo "  CLUSTERNAME   Name for the Kind cluster (default: hbr-cluster)"
    exit 0
}

# Default cluster name
CLUSTERNAME="hbr-cluster"

# Parse options using getopts
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            CLUSTERNAME="$1"
            shift
            ;;
    esac
done

echo "Cluster Name: ${CLUSTERNAME}"

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIND_CONFIG="${SCRIPT_DIR}/config.yml"
# KUBECONFIG_PATH="${SCRIPT_DIR}/kubeconfig-${CLUSTERNAME}.yaml"

echo "Kind Config Path: ${KIND_CONFIG}"

# Verify config.yml exists
if [[ ! -f "${KIND_CONFIG}" ]]; then
    echo "Error: Configuration file '${KIND_CONFIG}' not found."
    exit 1
fi

# Check if the Kind cluster already exists
if "${KIND_CMD}" get clusters | grep -qw "${CLUSTERNAME}"; then
    echo "Kind cluster '${CLUSTERNAME}' already exists."
    read -r -p "Do you want to delete the existing cluster and recreate it? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            sudo "${KIND_CMD}" delete cluster --name "${CLUSTERNAME}"
            echo "Existing Kind cluster '${CLUSTERNAME}' deleted."
            ;;
        *)
            echo "Exiting without making changes."
            exit 0
            ;;
    esac
fi

# Create Kind cluster
sudo "${KIND_CMD}" create cluster --name "${CLUSTERNAME}" --config "${KIND_CONFIG}"
echo "Kind cluster '${CLUSTERNAME}' created successfully."
echo " --- "

# Deploy NGINX Ingress Controller
INGRESS_DEPLOY_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
sudo "${KUBECTL_CMD}" apply -f "${INGRESS_DEPLOY_URL}"
echo "NGINX Ingress Controller deployment initiated."
echo " --- "

# Wait for Ingress Controller pods
INGRESS_NAMESPACE="ingress-nginx"
INGRESS_SELECTOR="app.kubernetes.io/component=controller"

sudo "${KUBECTL_CMD}" wait --namespace "${INGRESS_NAMESPACE}" --for=condition=ready pod --selector="${INGRESS_SELECTOR}" --timeout=90s
echo "NGINX Ingress Controller pods are ready."
echo " --- "

echo "Kubernetes cluster '${CLUSTERNAME}' is now ready with NGINX Ingress Controller deployed."
