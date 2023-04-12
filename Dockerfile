FROM alpine:3.17.3

COPY .bashrc /root/.bashrc
COPY .nanorc /root/.nanorc
RUN mkdir /root/.kube
# this is the config file for k8s
COPY config /root/.kube/config
ENV KUBECONFIG /root/.kube/config

# this YAML can be used to apply patches needed to open ports for ingresses under Kind
# if you create a cluster without referring to this file you'll later need to apply them manually
# it is recommended to add the flag --config=/root/config.yml when creating new clusters
COPY config.yml /root/config.yml
# you will also need to deploy one of the available ingress controllers that will listen on 80/443 ports
# check this document to learn how to deploy them: 
# NGINX: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
# Contour: https://kind.sigs.k8s.io/docs/user/ingress/#contour
# Kong: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-kong

# helper script that installs k8s clusters and deploys nginx ingress controllers
COPY create_cluster.sh /root/create_cluster.sh
RUN chmod +x /root/create_cluster.sh

RUN apk update

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
	apache2-utils

# DevOps stuff
ENV DOCKER_VERSION 20.10.24-r1
RUN apk add --no-cache \
	docker=${DOCKER_VERSION}

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl

# helm
ENV HELM_VERSION 3.10.2-r3
RUN apk add --no-cache \
	helm=${HELM_VERSION}

# terraform
ENV TF_VERSION 1.3.4-r3
RUN apk add --no-cache \
	terraform=${TF_VERSION}

# kind
ENV KIND_VERSION 0.18.0
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/bin/kind

ENTRYPOINT [ "bash" ]
