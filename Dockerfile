FROM alpine:3.17.3

ENV HOME /root
ENV COMPLETIONS /usr/share/bash-completion/completions

COPY .bashrc $HOME/.bashrc
COPY .nanorc $HOME/.nanorc
RUN mkdir $HOME/.kube
# this is the config file for k8s
COPY config $HOME/.kube/config
RUN chmod o-r $HOME/.kube/config
RUN chmod g-r $HOME/.kube/config
ENV KUBECONFIG $HOME/.kube/config

# this YAML can be used to apply patches needed to open ports for ingresses under Kind
# if you create a cluster without referring to this file you'll later need to apply them manually
# it is recommended to add the flag --config=/root/config.yml when creating new clusters
COPY config.yml $HOME/config.yml
# you will also need to deploy one of the available ingress controllers that will listen on 80/443 ports
# check this document to learn how to deploy them: 
# NGINX: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
# Contour: https://kind.sigs.k8s.io/docs/user/ingress/#contour
# Kong: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-kong

# helper script that installs k8s clusters and deploys nginx ingress controllers
COPY create_cluster.sh $HOME/create_cluster.sh
RUN chmod +x $HOME/create_cluster.sh

# basic stuff
RUN	apk add --no-cache \
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
	python3

# Docker
# https://www.docker.com/
ENV DOCKER_VERSION 20.10.24-r1
RUN apk add --no-cache \
	docker=${DOCKER_VERSION}

ENV COMPOSE_VERSION 1.29.2-r2
RUN apk add docker-compose=${COMPOSE_VERSION}

# kubectl
# https://kubernetes.io/docs/reference/kubectl/
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
	-s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl
RUN kubectl completion bash > $COMPLETIONS/kubectl.bash

# kubecolor
RUN go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

# helm
# https://helm.sh/
ENV HELM_VERSION 3.11.3
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN chmod +x linux-amd64/helm
RUN mv linux-amd64/helm /usr/bin/helm
RUN rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

# terraform
# https://www.terraform.io/
ENV TF_VERSION 1.4.5
RUN curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN unzip -x terraform_${TF_VERSION}_linux_amd64.zip
RUN chmod +x terraform
RUN mv ./terraform /usr/bin/terraform
RUN rm terraform_${TF_VERSION}_linux_amd64.zip

# kind
# https://kind.sigs.k8s.io/
ENV KIND_VERSION 0.18.0
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/bin/kind

# kubectl's plugin manager krew
# https://krew.sigs.k8s.io/
ENV KREW_VERSION 0.4.3
RUN mkdir /tmp/krew \
	&& cd /tmp/krew \
	&& curl -fsSL https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz \
	| tar -zxf- \
	&& ./krew-linux_amd64 install krew \
	&& cd \
	&& rm -rf /tmp/krew \
	&& echo export 'PATH=$HOME/.krew/bin:$PATH' >> .bashrc

# kubectx and kubens for k8s
# https://github.com/ahmetb/kubectx
RUN cd /tmp \
	&& git clone https://github.com/ahmetb/kubectx \
	&& cd kubectx \
	&& mv kubectx /usr/bin/kubectx \
	&& mv kubens /usr/bin/kubens \
	&& mv completion/*.bash $COMPLETIONS \
	&& cd .. \
	&& rm -rf kubectx

ENTRYPOINT [ "bash" ]
