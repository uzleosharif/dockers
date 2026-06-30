

FROM quay.io/sharpreflections/rocky8-build:latest

ARG NVIM_VERSION=v0.12.3

RUN \
  dnf install -y \
  rust \
  cargo \
  jq \
  git \
  gcc \
  gcc-c++ \
  make \
  cmake \
  ninja-build \
  gettext \
  curl \
  glibc-gconv-extra \
  ncurses-term \
  kitty-terminfo \
  fontconfig \
  google-noto-emoji-fonts \
  chafa \
  w3m \
  fish \
  unzip && \
  dnf clean all && \
  rm -rf /var/cache/dnf

RUN dnf -y install curl ca-certificates git && \
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf -y module disable nodejs && \
    dnf -y install nodejs && \
    npm install -g @github/copilot && \
    dnf clean all

RUN set -euo pipefail; \
  # neovim
  curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/archive/refs/tags/${NVIM_VERSION}.tar.gz"; \
  mkdir -p /tmp/nvim-src; \
  tar -xzf /tmp/nvim.tar.gz -C /tmp/nvim-src --strip-components=1; \
  mkdir -p /tmp/nvim-src/.deps/build/downloads/treesitter_lua; \
  curl -fsSL -o /tmp/nvim-src/.deps/build/downloads/treesitter_lua/v0.5.0.tar.gz \
  "https://api.github.com/repos/tree-sitter-grammars/tree-sitter-lua/tarball/refs/tags/v0.5.0"; \
  CMAKE_BUILD_PARALLEL_LEVEL=1 make -C /tmp/nvim-src deps CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local; \
  make -C /tmp/nvim-src CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local; \
  make -C /tmp/nvim-src install; \
  ln -sf /usr/local/bin/nvim /usr/bin/nvim; \
  rm -rf /tmp/nvim-src /tmp/nvim.tar.gz; \
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
  # tree-sitter-cli
  cargo install --root /usr/local tree-sitter-cli --version 0.20.8 --locked; \
  rm -rf /root/.cargo/registry /root/.cargo/git; \
  # mermaid-cli
  npm install -g @mermaid-js/mermaid-cli; \
  # codex
  npm install -g @openai/codex
