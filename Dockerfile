FROM alpine

COPY .bashrc /root/.bashrc
COPY .nanorc /root/.nanorc

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
# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl
# helm
RUN apk add --no-cache \
	helm
# terraform
RUN apk add --no-cache \
	terraform

# kind
ENV KIND_VERSION 0.18.0
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/local/bin/kind

ENTRYPOINT [ "bash" ]
