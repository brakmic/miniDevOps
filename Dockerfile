###############################################################################
#                           Stage 1: Builder
###############################################################################
FROM debian:bookworm-slim AS builder

###############################################################################
# ARGS and ENVs
###############################################################################
ARG HOME_DIR="/root"
ENV HOME=$HOME_DIR
ENV GOBIN=/usr/local/bin
ENV COMPLETIONS=/usr/share/bash-completion/completions
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


###############################################################################
# (1) Enable contrib and non-free repositories
###############################################################################
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

###############################################################################
# (2) Install dependencies for building tools, including non-free packages
###############################################################################
RUN apt update && apt install -y --no-install-recommends \
    bash-completion \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    locales

# Configure locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

###############################################################################
# (3) Install Go
###############################################################################
ARG GO_VERSION=1.23.6
RUN curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=/usr/local/go/bin:${PATH}

###############################################################################
# (4) Install Tools
###############################################################################

# 4a) kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && mkdir -p ${COMPLETIONS} \
    && kubectl completion bash > ${COMPLETIONS}/kubectl

# 4b) kubecolor, stern
ENV CGO_ENABLED=1
RUN go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest \
    && go install github.com/stern/stern@latest

# 4c) Helm
ARG HELM_VERSION=3.17.0
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm completion bash > ${COMPLETIONS}/helm \
    && rm -rf linux-amd64 helm-v${HELM_VERSION}-linux-amd64.tar.gz

# 4d) Terraform
ARG TF_VERSION=1.10.5
RUN curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform_${TF_VERSION}_linux_amd64.zip

# 4e) Skaffold
RUN curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 \
    && chmod +x /usr/local/bin/skaffold \
    && skaffold completion bash > ${COMPLETIONS}/skaffold

# 4f) kubeseal
ARG KUBESEAL_VERSION=0.28.0
RUN curl -LO "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" \
    && tar -zxvf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz \
    && mv kubeseal /usr/local/bin/kubeseal \
    && chmod +x /usr/local/bin/kubeseal \
    && rm kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz

# 4g) Kind
ARG KIND_VERSION=0.26.0
RUN curl -Lo kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 \
    && chmod +x kind \
    && mv kind /usr/local/bin/kind \
    && kind completion bash > ${COMPLETIONS}/kind

# 4h) kubectx + kubens
RUN cd /tmp && git clone https://github.com/ahmetb/kubectx.git \
    && cd kubectx \
    && mv kubectx /usr/local/bin/kubectx \
    && mv kubens /usr/local/bin/kubens \
    && mv completion/*.bash ${COMPLETIONS} \
    && cd /tmp \
    && rm -rf kubectx

# 4i) kubelogin
ARG KUBELOGIN_VERSION=0.1.7
RUN curl -LO https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip \
    && unzip kubelogin-linux-amd64.zip -d kubelogin \
    && mv kubelogin/bin/linux_amd64/kubelogin /usr/local/bin \
    && chmod +x /usr/local/bin/kubelogin \
    && rm -rf kubelogin kubelogin-linux-amd64.zip

# 4j) lazydocker
RUN DIR=/usr/local/bin \
    curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# 4k) usql
ARG USQL_VERSION=0.19.16
RUN curl -LO https://github.com/xo/usql/releases/download/v${USQL_VERSION}/usql-${USQL_VERSION}-linux-amd64.tar.bz2 \
    && tar -xjf usql-${USQL_VERSION}-linux-amd64.tar.bz2 \
    && mv usql /usr/local/bin/usql \
    && chmod +x /usr/local/bin/usql \
    && rm usql-${USQL_VERSION}-linux-amd64.tar.bz2

# 4l) Operator SDK
ARG OPERATOR_SDK_VERSION=1.39.1
RUN set -eux; \
    ARCH=$(case $(uname -m) in \
      x86_64)  echo -n amd64 ;; \
      aarch64) echo -n arm64 ;; \
      *)       echo -n $(uname -m) ;; \
    esac); \
    OS=$(uname | awk '{print tolower($0)}'); \
    export OPERATOR_SDK_DL_URL="https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_SDK_VERSION}"; \
    curl -LO "${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}"; \
    chmod +x "operator-sdk_${OS}_${ARCH}"; \
    mv "operator-sdk_${OS}_${ARCH}" /usr/local/bin/operator-sdk

# 4m) Flux
RUN curl -s https://fluxcd.io/install.sh | bash \
    && flux completion bash > ${COMPLETIONS}/flux

# 4n) K9s
ARG K9S_VERSION=0.32.7
RUN curl -Lo /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz \
    && tar -C /tmp -xzf /tmp/k9s.tar.gz k9s \
    && mv /tmp/k9s /usr/local/bin/k9s \
    && chmod +x /usr/local/bin/k9s \
    && rm /tmp/k9s.tar.gz

###############################################################################
#                           Stage 2: Runner
###############################################################################
FROM debian:bookworm-slim AS runner

###############################################################################
# ARGS and ENVs
###############################################################################
ARG USER=minidevops
ENV RUNNER_HOME=/home/${USER}
ENV HOME=${RUNNER_HOME}

ENV PIPENV_VERBOSITY=-1

# Derived directories
ENV KREW_DIR=$HOME/.krew
ENV VENV_DIR=$HOME/.venv

###############################################################################
# (1) Enable contrib and non-free repositories
###############################################################################
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

###############################################################################
# (2) Install dependencies, including non-free packages
###############################################################################
RUN apt update && apt install -y --no-install-recommends \
    sudo \
    bash \
    bash-completion \
    locales \
    ca-certificates \
    git \
    python3 \
    python3-pip \
    python3-venv \
    gcc \
    make \
    nano \
    vim \
    htop \
    curl \
    gnupg \
    dpkg \
    lsb-release \
    iputils-ping \
    dnsutils \
    hping3 \
    manpages-posix \
    man-db \
    tree \
    openssl \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt clean && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

###############################################################################
# (3) Install Docker
###############################################################################
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-ce.gpg \
    && chmod a+r /usr/share/keyrings/docker-ce.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://download.docker.com/linux/debian $(lsb_release -sc) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update \
    && apt install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt clean && rm -rf /var/lib/apt/lists/*

###############################################################################
# (4) Create non-root user with sudo and Docker group
###############################################################################
RUN adduser --disabled-password --gecos "" --uid 1000 ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER} \
    && usermod -aG docker ${USER}

###############################################################################
# (5) Copy binaries and configurations from builder
###############################################################################
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/share/bash-completion/completions /usr/share/bash-completion/completions
# COPY --from=builder /root/.krew $HOME/.krew
# COPY --from=builder /root/.venv $HOME/.venv

# Put the user’s config in /home/minidevops
COPY .bashrc $HOME/.bashrc
COPY .bash_completion $HOME/.bash_completion
COPY .nanorc $HOME/.nanorc
COPY config.yml $HOME/config.yml
COPY create_cluster.sh $HOME/create_cluster.sh

# Put the kube config in the user’s home
RUN mkdir -p $HOME/.kube
COPY config $HOME/.kube/config

# Put the entrypoint + welcome script in /tmp
COPY start.sh /tmp/start.sh
COPY welcome_message.sh /tmp/welcome_message.sh

###############################################################################
# Krew - plugin manager for kubectl
###############################################################################
ARG KREW_VERSION=0.4.4
RUN mkdir -p /tmp/krew \
    && cd /tmp/krew \
    && curl -fsSL https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz \
    | tar -zxf- \
    && ./krew-linux_amd64 install krew \
    && cd $HOME \
    && rm -rf /tmp/krew \
    && echo "export PATH=\$PATH:$KREW_DIR/bin" >> $HOME/.bashrc

###############################################################################
# Python environment + pipenv + kube-shell
###############################################################################
ENV VENV_DIR=$HOME/.venv
RUN python3 -m venv $VENV_DIR \
    && . $VENV_DIR/bin/activate \
    && pip install --upgrade pip \
    && pip install pipenv

COPY Pipfile* $HOME/
RUN . $VENV_DIR/bin/activate \
    && cd $HOME \
    && if [ -f "Pipfile" ]; then pipenv install --deploy; fi \
    && deactivate

###############################################################################
# (6) Set permissions and ownership
###############################################################################
RUN chown -R ${USER}:${USER} $HOME \
    && chmod +x /tmp/start.sh $HOME/create_cluster.sh \
    && chmod o-r $HOME/.kube/config \
    && chmod g-r $HOME/.kube/config \
    && cat /tmp/welcome_message.sh >> $HOME/.bashrc \
    && rm /tmp/welcome_message.sh

###############################################################################
# (7) Set Working Directory and Switch User
###############################################################################
WORKDIR $HOME
USER ${USER}

###############################################################################
# (8) Set Environment Variables and Entrypoint
###############################################################################
ENV PATH=$HOME/.krew/bin:$HOME/.venv/bin:$PATH
ENV PS1="\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ "
ENTRYPOINT ["/tmp/start.sh"]

CMD ["bash"]
