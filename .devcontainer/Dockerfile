FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    curl \
    git \
    sudo \
    locales \
    build-essential \
    fonts-lmodern \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-freefont-ttf \
    fontconfig \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-pictures \
    texlive-bibtex-extra \
    texlive-lang-english \
    texlive-xetex \
    texlive-luatex \
    latexmk \
    poppler-utils \
    ghostscript \
 && locale-gen en_US.UTF-8 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

WORKDIR /workspace
FROM blang/latex:latest

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user to match VS Code remote user expectations
RUN apt-get update || true
RUN if ! id -u ${USERNAME} >/dev/null 2>&1; then \
      groupadd -g ${USER_GID} ${USERNAME} || true && \
      useradd -m -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USERNAME} || true; \
    fi

# Ensure workspace directory exists and is owned by the non-root user
RUN mkdir -p /workspace && chown ${USERNAME}:${USERNAME} /workspace

WORKDIR /workspace

CMD ["/bin/bash"]
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# Install TeX Live (full) to ensure Beamer and common packages are available.
# Note: texlive-full is large; swap to smaller collections if you want a smaller image.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        texlive-full \
        latexmk \
        biber \
        make \
        git \
        wget \
        curl \
        ca-certificates \
        python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a workspace directory and set permissions for the default 'vscode' user
RUN mkdir -p /workspace && chown vscode:root /workspace

WORKDIR /workspace

CMD ["/bin/bash"]
