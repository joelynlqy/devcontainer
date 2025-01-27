FROM public.ecr.aws/ubuntu/ubuntu:noble

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    locales \
    sudo \
    pipx \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/.cache/code-server \
    && curl -#fL -o ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete -C - https://github.com/coder/code-server/releases/download/v4.96.2/code-server_4.96.2_amd64.deb \
    && mv ~/.cache/code-server/code-server_4.96.2_amd64.deb.incomplete ~/.cache/code-server/code-server_4.96.2_amd64.deb \
    && sudo dpkg -i ~/.cache/code-server/code-server_4.96.2_amd64.deb

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
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

# Install pipx packages
RUN pipx ensurepath
RUN pipx install -q notebook jupyterlab

