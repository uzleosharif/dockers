# this is meant to provide:
# - general goodies for linux-based dev
# - packages needed for nvim (editor)
# - clang toolchain

FROM ubuntu:25.10


# hadolint ignore=DL3008
RUN \
  apt-get -qq update && apt-get upgrade -qq -y && \
  apt-get install --no-install-recommends -qq -y \
  fish \
  unzip \
  git \
  ripgrep \
  fd-find \
  locales \
  build-essential \
  ninja-build \
  ca-certificates \
  curl \
  wget \
  htop \
  vim \
  openssh-client \
  nodejs \
  npm \
  screen \
  clang \
  clangd \
  clang-format \
  clang-tidy \
  libc++-dev \
  libc++abi-dev \
  libclang-rt-20-dev \
  lld \
  llvm-dev \
  file && \
  rm -rf /var/lib/apt/lists/* && \
  locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8


# hadolint ignore=DL3016
RUN \
  # neovim
  wget --no-check-certificate -q https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz && \
  tar zxf nvim-linux-x86_64.tar.gz && \
  ln -sf /nvim-linux-x86_64/bin/nvim /usr/bin/nvim && \
  rm nvim-linux-x86_64.tar.gz && \
  # hadolint
  wget -q -O /usr/local/bin/hadolint \
  "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64" && \
  chmod +x /usr/local/bin/hadolint && \
  # lazygit
  wget --no-check-certificate -q https://github.com/jesseduffield/lazygit/releases/download/v0.50.0/lazygit_0.50.0_Linux_x86_64.tar.gz && \
  tar zxf lazygit_0.50.0_Linux_x86_64.tar.gz && \
  mv lazygit /usr/bin/. && \
  # codex
  npm install -g @openai/codex

WORKDIR /work
