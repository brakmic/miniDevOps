#!/usr/bin/env bash
set -euo pipefail

FLAGFILE="${HOME}/.welcome_shown"

if [ ! -f "$FLAGFILE" ]; then

  echo -e "\n\033[1;32mWelcome to miniDevOps: Your DevOps Toolkit in Docker\n\033[0m"
  echo -e "\033[1;34mA containerized environment with tools for Kubernetes and DevOps.\n\033[0m"
  echo -e "\033[1;36mIncluded tools:\033[0m"
  echo -e "  kubectl, helm, terraform, kind, k9s, stern, kubecolor"
  echo -e "  skaffold, flux, kubeseal, operator-sdk, kubelogin"
  echo -e "  lazydocker, popeye, kubectx, kubens, krew, usql"
  echo -e "  python, pipenv, docker, docker compose\n"
  echo -e "\033[1;33mQuick start:\033[0m"
  echo -e "  kind create cluster --name my-cluster"
  echo -e "  kubectl get pods"
  echo -e "  helm install <name> <chart>"
  echo -e "  terraform init && terraform apply\n"
  echo -e "\033[1;35mGitHub:\033[0m \033[4mhttps://github.com/brakmic/miniDevOps\033[0m\n"

  touch "$FLAGFILE"

fi

