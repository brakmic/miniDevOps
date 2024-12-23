#!/usr/bin/env bash

FLAGFILE="${HOME}/.welcome_shown"

if [ ! -f "$FLAGFILE" ]; then

  echo -e "\n\033[1;32m🚀 Welcome to miniDevOps: Your DevOps Toolkit Operated within Docker! 🚀\n\033[0m"
  echo -e "\033[1;34mThis Docker environment is your ultimate set of tools for Kubernetes and DevOps magic.\n\033[0m"
  echo -e "\n\033[1;36m🐍 Python & Pipenv: \033[0m"
  echo -e "  🛠 Develop Python scripts: pipenv install <package> & pipenv run python <script.py>\n"
  echo -e "\033[1;33m🔱 Kubernetes: \033[0m"
  echo -e "  🛠 Launch your cluster: kind create cluster --name my-cluster"
  echo -e "  🌐 Manage your deployments: kubectl get pods\n"
  echo -e "\033[1;35m⚓ Helm: \033[0m"
  echo -e "  🎁 Orchestrate with Helm: helm install <name> <chart>\n"
  echo -e "\033[1;32m🌿 Terraform: \033[0m"
  echo -e "  🛠 Initialize & Apply Configs: terraform init && terraform apply\n"
  echo -e "\033[1;34m🐳 Docker & Compose: \033[0m"
  echo -e "  🚀 Manage Containers: docker ps"
  echo -e "  🌟 Orchestrate Services: docker compose up -d\n\033[0m"
  echo -e "\033[1;35m🔗 GitHub Repository: \033[0m"
  echo -e "  🌟 Check out our code, report issues or contribute: \033[4mhttps://github.com/brakmic/miniDevOps\033[0m"
  echo -e "\n\033[1;33m⭐ If you find this Docker image helpful, please consider giving us a star on GitHub! ⭐\n\033[0m"

  touch $FLAGFILE

fi

