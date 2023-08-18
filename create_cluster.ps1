param (
    [string]$CLUSTERNAME = $(throw "CLUSTERNAME is required")
)

# Create cluster
kind create cluster --name $CLUSTERNAME --config=config.yml

Write-Host " --- "
Write-Host " --- Deploying NGINX IngressController ---"

# Deploy NGINX IngressController
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

Write-Host " --- Waiting for deployment to complete ---"

# Wait for deployment to complete
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

Write-Host " --- k8s is now ready --- "
