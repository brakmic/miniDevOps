###############################################################################
#                           Stage 1: Builder
###############################################################################
FROM debian:bookworm-slim AS builder

###############################################################################
# Version ARGs
###############################################################################
ARG FLUX_VERSION=2.8.3
ARG GO_VERSION=1.26.1
ARG HELM_VERSION=4.1.3
ARG K9S_VERSION=0.50.18
ARG KIND_VERSION=0.31.0
ARG KREW_VERSION=0.5.0
ARG KUBECOLOR_VERSION=0.5.3
ARG KUBECTX_VERSION=0.11.0
ARG KUBELOGIN_VERSION=0.2.16
ARG KUBESEAL_VERSION=0.36.1
ARG LAZYDOCKER_VERSION=0.25.0
ARG OPERATOR_SDK_VERSION=1.42.2
ARG POPEYE_VERSION=0.22.1
ARG SKAFFOLD_VERSION=2.18.2
ARG STERN_VERSION=1.33.1
ARG TF_VERSION=1.14.8
ARG USQL_VERSION=0.21.4

###############################################################################
# Build environment
###############################################################################
ARG HOME_DIR="/root"
ENV HOME=$HOME_DIR
ENV GOBIN=/usr/local/bin
ENV COMPLETIONS=/usr/share/bash-completion/completions
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


###############################################################################
# (1) Enable contrib and non-free repositories
# Duplicated in runner stage because each stage starts from a clean base image.
###############################################################################
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

###############################################################################
# (2) Install build dependencies
###############################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

###############################################################################
# (3) Install Go
###############################################################################
RUN curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz"
ENV PATH=/usr/local/go/bin:${PATH}

###############################################################################
# (4) Tools
###############################################################################

# kubectl tracks the latest stable release.
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && mkdir -p ${COMPLETIONS} \
    && kubectl completion bash > ${COMPLETIONS}/kubectl

# kubecolor
RUN curl -Lo /tmp/kubecolor.tar.gz \
        "https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/kubecolor_${KUBECOLOR_VERSION}_linux_amd64.tar.gz" \
    && tar -C /tmp -xzf /tmp/kubecolor.tar.gz kubecolor \
    && mv /tmp/kubecolor /usr/local/bin/kubecolor \
    && chmod +x /usr/local/bin/kubecolor \
    && rm /tmp/kubecolor.tar.gz

# stern
RUN curl -Lo /tmp/stern.tar.gz \
        "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz" \
    && tar -C /tmp -xzf /tmp/stern.tar.gz stern \
    && mv /tmp/stern /usr/local/bin/stern \
    && chmod +x /usr/local/bin/stern \
    && stern --completion bash > ${COMPLETIONS}/stern \
    && rm /tmp/stern.tar.gz

# Helm
RUN curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && curl -sL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256sum" | sha256sum -c - \
    && tar -zxf "helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm completion bash > ${COMPLETIONS}/helm \
    && rm -rf linux-amd64 "helm-v${HELM_VERSION}-linux-amd64.tar.gz"

# Terraform
RUN curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
    && curl -sL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS" \
    | grep "terraform_${TF_VERSION}_linux_amd64.zip" \
    | sha256sum -c - \
    && unzip "terraform_${TF_VERSION}_linux_amd64.zip" \
    && mv terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm "terraform_${TF_VERSION}_linux_amd64.zip"

# Skaffold
RUN curl -Lo /usr/local/bin/skaffold \
        "https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-amd64" \
    && chmod +x /usr/local/bin/skaffold \
    && skaffold completion bash > ${COMPLETIONS}/skaffold

# kubeseal
RUN curl -LO "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" \
    && tar -zxf "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" kubeseal \
    && mv kubeseal /usr/local/bin/kubeseal \
    && chmod +x /usr/local/bin/kubeseal \
    && rm "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"

# Kind
RUN curl -Lo kind "https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64" \
    && chmod +x kind \
    && mv kind /usr/local/bin/kind \
    && kind completion bash > ${COMPLETIONS}/kind

# kubectx + kubens
RUN curl -Lo /tmp/kubectx.tar.gz \
        "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    && tar -C /tmp -xzf /tmp/kubectx.tar.gz kubectx \
    && mv /tmp/kubectx /usr/local/bin/kubectx \
    && rm /tmp/kubectx.tar.gz \
    && curl -Lo /tmp/kubens.tar.gz \
        "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubens_v${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    && tar -C /tmp -xzf /tmp/kubens.tar.gz kubens \
    && mv /tmp/kubens /usr/local/bin/kubens \
    && rm /tmp/kubens.tar.gz

# kubelogin
RUN curl -LO "https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip" \
    && unzip kubelogin-linux-amd64.zip -d kubelogin \
    && mv kubelogin/bin/linux_amd64/kubelogin /usr/local/bin \
    && chmod +x /usr/local/bin/kubelogin \
    && rm -rf kubelogin kubelogin-linux-amd64.zip

# lazydocker
RUN curl -Lo /tmp/lazydocker.tar.gz \
        "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz" \
    && tar -C /tmp -xzf /tmp/lazydocker.tar.gz lazydocker \
    && mv /tmp/lazydocker /usr/local/bin/lazydocker \
    && chmod +x /usr/local/bin/lazydocker \
    && rm /tmp/lazydocker.tar.gz

# usql
RUN go install -ldflags "-X github.com/xo/usql/text.CommandVersion=${USQL_VERSION}" \
        github.com/xo/usql@v${USQL_VERSION}

# Operator SDK (simplified to linux/amd64 target only)
RUN curl -LO "https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_SDK_VERSION}/operator-sdk_linux_amd64" \
    && chmod +x operator-sdk_linux_amd64 \
    && mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk

# Flux
RUN curl -Lo /tmp/flux.tar.gz \
        "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" \
    && tar -C /tmp -xzf /tmp/flux.tar.gz flux \
    && mv /tmp/flux /usr/local/bin/flux \
    && chmod +x /usr/local/bin/flux \
    && flux completion bash > ${COMPLETIONS}/flux \
    && rm /tmp/flux.tar.gz

# K9s
RUN curl -Lo /tmp/k9s.tar.gz \
        "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
    && tar -C /tmp -xzf /tmp/k9s.tar.gz k9s \
    && mv /tmp/k9s /usr/local/bin/k9s \
    && chmod +x /usr/local/bin/k9s \
    && rm /tmp/k9s.tar.gz

# Popeye
RUN curl -Lo /tmp/popeye.tar.gz \
        "https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_linux_amd64.tar.gz" \
    && tar -C /tmp -xzf /tmp/popeye.tar.gz popeye \
    && mv /tmp/popeye /usr/local/bin/popeye \
    && chmod +x /usr/local/bin/popeye \
    && popeye completion bash > ${COMPLETIONS}/popeye \
    && rm /tmp/popeye.tar.gz

# Krew
RUN mkdir -p /tmp/krew \
    && cd /tmp/krew \
    && curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz" \
    | tar -zxf- \
    && mv ./krew-linux_amd64 /usr/local/bin/kubectl-krew \
    && cd / \
    && rm -rf /tmp/krew

###############################################################################
# (5) Verify all tool binaries exist
###############################################################################
RUN kubectl version --client \
    && helm version --short \
    && terraform version \
    && kind version \
    && k9s version --short \
    && stern --version \
    && skaffold version \
    && kubeseal --version \
    && flux --version \
    && operator-sdk version \
    && kubelogin --version \
    && lazydocker --version \
    && popeye version \
    && usql --version \
    && kubectx --help > /dev/null \
    && kubens --help > /dev/null \
    && kubectl-krew version

###############################################################################
#                           Stage 2: Runner
###############################################################################
FROM debian:bookworm-slim AS runner

LABEL org.opencontainers.image.source="https://github.com/brakmic/miniDevOps" \
      org.opencontainers.image.description="DevOps toolkit with Kubernetes, Helm, Terraform, and more" \
      org.opencontainers.image.licenses="MIT"

###############################################################################
# Environment
###############################################################################
ARG USER=minidevops
ENV RUNNER_HOME=/home/${USER}
ENV HOME=${RUNNER_HOME}
ENV PIPENV_VERBOSITY=-1
ENV KREW_DIR=$HOME/.krew
ENV VENV_DIR=$HOME/.venv

###############################################################################
# (1) Enable contrib and non-free repositories
# Duplicated from builder; each stage starts from a clean base image.
###############################################################################
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

###############################################################################
# (2) Install runtime dependencies
###############################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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

COPY .bashrc $HOME/.bashrc
COPY .bash_completion $HOME/.bash_completion
COPY .nanorc $HOME/.nanorc
COPY config.yml $HOME/config.yml
COPY create_cluster.sh $HOME/create_cluster.sh
RUN mkdir -p $HOME/.kube
COPY config $HOME/.kube/config
COPY start.sh /tmp/start.sh
COPY welcome_message.sh /tmp/welcome_message.sh

###############################################################################
# Python environment + pipenv
###############################################################################
RUN python3 -m venv $VENV_DIR \
    && . $VENV_DIR/bin/activate \
    && pip install --upgrade pip \
    && pip install pipenv

COPY Pipfile* $HOME/
RUN . $VENV_DIR/bin/activate \
    && cd $HOME \
    && if [ -f "Pipfile" ]; then pipenv install; fi \
    && deactivate

###############################################################################
# Create tool configuration directories
###############################################################################
RUN mkdir -p $HOME/.config/popeye \
    && mkdir -p $HOME/.krew

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
# (8) Environment and Entrypoint
###############################################################################
ENV PATH=$HOME/.krew/bin:$HOME/.venv/bin:$PATH
ENV PS1="\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ "
ENTRYPOINT ["/tmp/start.sh"]

CMD ["bash"]
