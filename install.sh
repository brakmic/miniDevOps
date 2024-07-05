#!/bin/sh

HOME=/root
COMPLETIONS=/usr/share/bash-completion/completions
DOCKER_VERSION=27.0.3-r1
DOCKER_CLI_VERSION=27.0.3-r1
COMPOSE_VERSION=2.28.1-r1
HELM_VERSION=3.14.0
TF_VERSION=1.9.1
KUBESEAL_VERSION=0.27.0
KIND_VERSION=0.23.0
KREW_VERSION=0.4.4
K9S_VERSION=0.32.5
DIR=/usr/bin
OP_SDK_DIR=$HOME/operator-sdk

chmod o-r $HOME/.kube/config
chmod g-r $HOME/.kube/config
chmod +x $HOME/create_cluster.sh

# Basic Stuff
apk add --no-cache \
	bash \
	bash-completion \
	ca-certificates \
	gcc \
	git \
	make \
	musl-dev \
	zip \
	nano \
	nano-syntax \
	vim \
	lynx \
	htop \
	wget \
	curl \
	apache2-ssl \
	apache2-utils \
	ncurses \
	go \
	python3 \
	py3-pip \
	jq \
	yq \
	ttf-dejavu

apk add --no-cache \
	docker=${DOCKER_VERSION} \
	docker-cli=${DOCKER_CLI_VERSION} \
	docker-cli-compose=${COMPOSE_VERSION}

# Install glibc compatibility layer for Alpine
wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-bin-2.35-r1.apk \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-i18n-2.35-r1.apk \
	&& apk add glibc-2.35-r1.apk \
	&& apk add glibc-bin-2.35-r1.apk \
	&& apk add glibc-i18n-2.35-r1.apk \
	&& rm -rf *.apk \
	&& /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
	&& /usr/glibc-compat/bin/localedef -i de_DE -f UTF-8 de_DE.UTF-8 \
	&& /usr/glibc-compat/bin/localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 \
	&& /usr/glibc-compat/bin/localedef -i es_ES -f UTF-8 es_ES.UTF-8 \
	&& /usr/glibc-compat/bin/localedef -i pt_PT -f UTF-8 pt_PT.UTF-8 \
	&& /usr/glibc-compat/bin/localedef -i zh_CN -f UTF-8 zh_CN.UTF-8

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
	-s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
	&& chmod +x ./kubectl \
	&& mv ./kubectl /usr/bin/kubectl \
	&& kubectl completion bash > $COMPLETIONS/kubectl.bash

go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest \
	&& go install github.com/stern/stern@latest

curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
	&& tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
	&& chmod +x linux-amd64/helm \
	&& mv linux-amd64/helm /usr/bin/helm \
	&& helm completion bash > $COMPLETIONS/helm.bash \
	&& rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
	&& unzip -x terraform_${TF_VERSION}_linux_amd64.zip \
	&& chmod +x terraform \
	&& mv ./terraform /usr/bin/terraform \
	&& rm terraform_${TF_VERSION}_linux_amd64.zip

curl -Lo /usr/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 \
	&& chmod +x /usr/bin/skaffold \
	&& skaffold completion bash > ${COMPLETIONS}/skaffold.bash

curl -LO https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz \
	&& tar -zxvf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz \
	&& chmod +x ./kubeseal \
	&& mv ./kubeseal /usr/bin/kubeseal

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 \
	&& chmod +x ./kind \
	&& mv ./kind /usr/bin/kind \
	&& kind completion bash > ${COMPLETIONS}/kind.bash

mkdir /tmp/krew \
	&& cd /tmp/krew \
	&& curl -fsSL https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz \
	| tar -zxf- \
	&& ./krew-linux_amd64 install krew \
	&& cd \
	&& rm -rf /tmp/krew \
	&& echo export 'PATH=$HOME/.krew/bin:$PATH' >> .bashrc

cd /tmp \
	&& git clone https://github.com/ahmetb/kubectx \
	&& cd kubectx \
	&& mv kubectx /usr/bin/kubectx \
	&& mv kubens /usr/bin/kubens \
	&& mv completion/*.bash $COMPLETIONS \
	&& cd .. \
	&& rm -rf kubectx

curl -Lo kubelogin.zip https://github.com/Azure/kubelogin/releases/download/v0.0.31/kubelogin-linux-amd64.zip \
	&& unzip -d kubelogin kubelogin.zip \
	&& mv kubelogin/bin/linux_amd64/kubelogin /usr/bin \
	&& rm -rf kubelogin

curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# Install usql with the following additional database drivers:
# cosmos    - for Microsoft Azure Cosmos DB support
# cassandra - for Apache Cassandra support
# bigquery  - for Google BigQuery support
# spanner   - for Google Cloud Spanner support
# adodb     - for Microsoft ActiveX Data Objects support
# presto    - for PrestoDB support
# sapase    - for SAP Adaptive Server Enterprise support
# saphana   - for SAP HANA support
go install -tags 'cosmos cassandra bigquery spanner adodb presto sapase saphana no_sqlite3' github.com/xo/usql@latest


# Install Operator SDK
export GOBIN=/usr/local/bin
git clone https://github.com/operator-framework/operator-sdk $OP_SDK_DIR \
	&& cd $HOME/operator-sdk \
	&& git checkout master \
	&& make install \
	&& cd $HOME \
	&& rm -rf $OP_SDK_DIR

# Install Flux CD
curl -s https://fluxcd.io/install.sh | bash \
	&& flux completion bash > ${COMPLETIONS}/flux.bash

# Install k9s
go install github.com/derailed/k9s@v${K9S_VERSION}

# Enter python virtual environment
python3 -m venv $HOME/.venv
. $HOME/.venv/bin/activate

# Install pipenv
pip install pipenv
cd $HOME

# Install Python packages from Pipfile
if [ -f "Pipfile" ]; then
  pipenv install --deploy
fi

# Exit the virtual environment
deactivate
