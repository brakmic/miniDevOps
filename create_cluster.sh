#!/bin/bash
CLUSTERNAME=$1

kind create cluster --name $CLUSTERNAME --config=config.yml
echo " --- "
echo " --- Deploying NGINX IngressController ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo " --- Waiting for deployment to complete ---"
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
echo " --- K8S is now ready --- "
