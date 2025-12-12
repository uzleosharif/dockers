# this is meant to provide:
# - general goodies for linux-based dev
# - packages needed for nvim (editor)
# - clang toolchain

FROM ubuntu:25.10

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
  tar \
  jq \
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
  lld \
  llvm-dev \
  file && \
  rm -rf /var/lib/apt/lists/* && \
  locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8


# hadolint ignore=DL3016
RUN set -euo pipefail; \
  # neovim (latest release)
  NVIM_JSON="$(wget -qO- https://api.github.com/repos/neovim/neovim/releases/latest)"; \
  NVIM_URL="$(printf '%s\n' "${NVIM_JSON}" | jq -r '.assets[] | select(.name=="nvim-linux-x86_64.tar.gz") | .browser_download_url' | head -n1)"; \
  test -n "${NVIM_URL}"; \
  NVIM_TAR="$(basename "${NVIM_URL}")"; \
  wget --no-check-certificate -q "${NVIM_URL}"; \
  tar zxf "${NVIM_TAR}"; \
  ln -sf "/nvim-linux-x86_64/bin/nvim" /usr/bin/nvim; \
  rm "${NVIM_TAR}"; \
  # hadolint
  wget -q -O /usr/local/bin/hadolint \
  "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64"; \
  chmod +x /usr/local/bin/hadolint; \
  # lazygit (latest release)
  LAZYGIT_JSON="$(wget -qO- https://api.github.com/repos/jesseduffield/lazygit/releases/latest)"; \
  LAZYGIT_URL="$(printf '%s\n' "${LAZYGIT_JSON}" | jq -r '.assets[] | select(.name | test("linux_x86_64\\.tar\\.gz$";"i")) | .browser_download_url' | head -n1)"; \
  test -n "${LAZYGIT_URL}"; \
  LAZYGIT_TAR="$(basename "${LAZYGIT_URL}")"; \
  wget --no-check-certificate -q "${LAZYGIT_URL}"; \
  tar zxf "${LAZYGIT_TAR}"; \
  mv lazygit /usr/bin/.; \
  rm "${LAZYGIT_TAR}"; \
  # codex
  npm install -g @openai/codex

WORKDIR /work
