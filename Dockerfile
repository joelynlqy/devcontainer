FROM public.ecr.aws/ubuntu/ubuntu:noble

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

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
    curl \
    htop \
    jq \
    locales \
    man \
    pipx \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    unzip \
    vim \
    wget \
    rsync && \
# Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    apt-get install --yes git \
    && rm -rf /var/lib/apt/lists/*

# Install pipx packages
RUN pipx install -q notebook jupyterlab apache-airflow

# Generate the desired locale (en_US.UTF-8)
RUN locale-gen en_US.UTF-8

# Make typing unicode characters in the terminal work.
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Remove the `ubuntu` user and add a user `coder` so that you're not developing as the `root` user
RUN userdel -r ubuntu && \
    useradd coder \
    --create-home \
    --shell=/bin/bash \
    --groups=docker \
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

# Install code-server
RUN mkdir -p ~/.cache/code-server \
    && curl -#fL -o ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete -C - https://github.com/coder/code-server/releases/download/v4.96.2/code-server_4.96.2_amd64.deb \
    && mv ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete ~/.cache/code-server/code-server_4.96.2_amd64.deb \
    && sudo dpkg -i ~/.cache/code-server/code-server_4.96.2_amd64.deb
# RUN mkdir -p ~/.cache/code-server \
#     && curl -fL -o ~/.cache/code-server/code-server-4.96.2-linux-amd64.tar.gz.incomplete -C - https://github.com/coder/code-server/releases/download/v4.96.2/code-server-4.96.2-linux-amd64.tar.gz \
#     && mv ~/.cache/code-server/code-server-4.96.2-linux-amd64.tar.gz.incomplete ~/.cache/code-server/code-server-4.96.2-linux-amd64.tar.gz \
#     && mkdir -p /tmp/code-server \
#     && sudo mkdir -p /tmp/code-server/lib /usr/bin \
#     && sudo tar -C /tmp/code-server/lib -xzf ~/.cache/codeserver/code-server-4.96.2-linux-amd64.tar.gz \
#     && sudo mv -f /tmp/code-server/lib/code-server-4.96.2-linux-amd64 /tmp/code-server/lib/code-server-4.96.2 \
#     && sudo ln -fs /tmp/code-server/lib/code-server-4.96.2/bin/code-server /usr/bin/code-server

# pre-install extensions on code-server
RUN /usr/bin/code-server --install-extension codeium.codeium-enterprise-updater \
    && /usr/bin/code-server --install-extension codeium.codeium \
    && /usr/bin/code-server --install-extension codezombiech.gitignore \
    && /usr/bin/code-server --install-extension dbaeumer.vscode-eslint \
    && /usr/bin/code-server --install-extension eamodio.gitlens \
    && /usr/bin/code-server --install-extension esbenp.prettier-vscode \
    && /usr/bin/code-server --install-extension formulahendry.auto-close-tag \
    && /usr/bin/code-server --install-extension formulahendry.auto-rename-tag \
    && /usr/bin/code-server --install-extension ms-azuretools.vscode-docker \
    && /usr/bin/code-server --install-extension ms-python.python \
    && /usr/bin/code-server --install-extension ms-vscode.vscode-typescript-tslint-plugin \
    && /usr/bin/code-server --install-extension redhat.vscode-yaml \
    && /usr/bin/code-server --install-extension vscode-icons-team.vscode-icons \
    && /usr/bin/code-server --install-extension waderyan.gitblame \
    && /usr/bin/code-server --install-extension yzhang.markdown-all-in-one

USER coder
# adds user's bin directory to PATH
RUN pipx ensurepath 
