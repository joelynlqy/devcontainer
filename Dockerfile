FROM public.ecr.aws/ubuntu/ubuntu:noble

# Install the Docker apt repository
RUN apt-get update && \
    apt-get upgrade --yes --no-install-recommends --no-install-suggests && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg
COPY docker.list /etc/apt/sources.list.d/docker.list

# Install baseline packages (What are the packages / tools that are commonly used by developers?)
RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
    bash \
    build-essential \
    containerd.io \
    curl \
    docker-ce \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin \
    htop \
    jq \
    locales \
    man \
    pipx \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    systemd \
    systemd-sysv \
    unzip \
    vim \
    wget \
    rsync && \
# Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    apt-get install --yes git \
    && rm -rf /var/lib/apt/lists/*



RUN mkdir -p ~/.cache/code-server \
    && curl -#fL -o ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete -C - https://github.com/coder/code-server/releases/download/v4.96.2/code-server_4.96.2_amd64.deb \
    && mv ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete ~/.cache/code-server/code-server_4.96.2_amd64.deb \
    && sudo dpkg -i ~/.cache/code-server/code-server_4.96.2_amd64.deb

RUN useradd -m -s /bin/bash -G sudo coder
USER coder
# Install pipx packages
RUN pipx install -q notebook jupyterlab
RUN pipx ensurepath
