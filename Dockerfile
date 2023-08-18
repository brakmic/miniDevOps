FROM alpine:3.18

ENV HOME /root
ENV COMPLETIONS /usr/share/bash-completion/completions

COPY .bashrc $HOME/.bashrc
COPY .bash_completion $HOME/.bash_completion
COPY .nanorc $HOME/.nanorc
RUN mkdir $HOME/.kube

COPY config $HOME/.kube/config
RUN chmod o-r $HOME/.kube/config
RUN chmod g-r $HOME/.kube/config
ENV KUBECONFIG $HOME/.kube/config

COPY config.yml $HOME/config.yml

COPY create_cluster.sh $HOME/create_cluster.sh
RUN chmod +x $HOME/create_cluster.sh

# Basic Stuff
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
	python3 \
	py3-pip \
	jq

# Install glibc compatibility layer for Alpine
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
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

# Set environment for unicode
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8


ENV DOCKER_VERSION 23.0.6-r4
RUN apk add --no-cache \
	docker=${DOCKER_VERSION}

ENV COMPOSE_VERSION 2.17.3-r5
RUN apk add docker-cli-compose=${COMPOSE_VERSION}

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
	-s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl
RUN kubectl completion bash > $COMPLETIONS/kubectl.bash

RUN go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
RUN go install github.com/stern/stern@latest

ENV HELM_VERSION 3.11.3
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN chmod +x linux-amd64/helm
RUN mv linux-amd64/helm /usr/bin/helm
RUN helm completion bash > $COMPLETIONS/helm.bash
RUN rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

ENV TF_VERSION 1.5.5
RUN curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN unzip -x terraform_${TF_VERSION}_linux_amd64.zip
RUN chmod +x terraform
RUN mv ./terraform /usr/bin/terraform
RUN rm terraform_${TF_VERSION}_linux_amd64.zip

RUN curl -Lo /usr/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
RUN chmod +x /usr/bin/skaffold
RUN skaffold completion bash > ${COMPLETIONS}/skaffold.bash

ENV KUBESEAL_VERSION 0.23.0
RUN curl -LO https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
RUN tar -zxvf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
RUN chmod +x ./kubeseal
RUN mv ./kubeseal /usr/bin/kubeseal

ENV KIND_VERSION 0.20.0
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/bin/kind
RUN kind completion bash > ${COMPLETIONS}/kind.bash

ENV KREW_VERSION 0.4.4
RUN mkdir /tmp/krew \
	&& cd /tmp/krew \
	&& curl -fsSL https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz \
	| tar -zxf- \
	&& ./krew-linux_amd64 install krew \
	&& cd \
	&& rm -rf /tmp/krew \
	&& echo export 'PATH=$HOME/.krew/bin:$PATH' >> .bashrc

RUN cd /tmp \
	&& git clone https://github.com/ahmetb/kubectx \
	&& cd kubectx \
	&& mv kubectx /usr/bin/kubectx \
	&& mv kubens /usr/bin/kubens \
	&& mv completion/*.bash $COMPLETIONS \
	&& cd .. \
	&& rm -rf kubectx

RUN curl -Lo kubelogin.zip https://github.com/Azure/kubelogin/releases/download/v0.0.31/kubelogin-linux-amd64.zip \
	&& unzip -d kubelogin kubelogin.zip \
	&& mv kubelogin/bin/linux_amd64/kubelogin /usr/bin \
	&& rm -rf kubelogin

ENV DIR /usr/bin
RUN curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# Install Operator SDK
ENV OP_SDK_DIR=$HOME/operator-sdk
RUN git clone https://github.com/operator-framework/operator-sdk $OP_SDK_DIR \
	&& cd $HOME/operator-sdk \
	&& git checkout master \
	&& make install \
	&& cd $HOME \
	&& rm -rf $OP_SDK_DIR

# Install pipenv
RUN pip3 install pipenv

# Copy Pipfile and Pipfile.lock, if available
COPY Pipfile* $HOME/

# Install Python packages from Pipfile into the system Python environment
RUN if [ -f "$HOME/Pipfile" ]; then cd $HOME && pipenv install --deploy --system; fi

# Install Fonts
RUN apk add --no-cache ttf-dejavu

ENV PS1 "\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "

# Add a Welcome Message for miniDevOps Docker Image Users
RUN echo 'echo -e "\n\033[1;32m🚀 Welcome to miniDevOps: Your DevOps Toolkit Operated within Docker! 🚀\n\033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;34mThis Docker environment is your ultimate set of tools for Kubernetes and DevOps magic.\n\033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "\n\033[1;36m🐍 Python & Pipenv: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🛠 Develop Python scripts: pipenv install <package> & pipenv run python <script.py>\n"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;33m🔱 Kubernetes: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🛠 Launch your cluster: kind create cluster --name my-cluster"' >> $HOME/.bashrc && \
	echo 'echo -e "  🌐 Manage your deployments: kubectl get pods\n"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;35m⚓ Helm: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🎁 Orchestrate with Helm: helm install <name> <chart>\n"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;32m🌿 Terraform: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🛠 Initialize & Apply Configs: terraform init && terraform apply\n"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;34m🐳 Docker & Compose: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🚀 Manage Containers: docker ps"' >> $HOME/.bashrc && \
	echo 'echo -e "  🌟 Orchestrate Services: docker compose up -d\n\033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "\033[1;35m🔗 GitHub Repository: \033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "  🌟 Check out our code, report issues or contribute: \033[4mhttps://github.com/brakmic/miniDevOps\033[0m"' >> $HOME/.bashrc && \
	echo 'echo -e "\n\033[1;33m⭐ If you find this Docker image helpful, please consider giving us a star on GitHub! ⭐\n\033[0m"' >> $HOME/.bashrc

ENTRYPOINT [ "bash" ]
