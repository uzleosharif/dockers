

FROM ubuntu:23.10

RUN apt update && apt upgrade -y && apt install -y \
    unzip git ripgrep fd-find locales curl wget build-essential
RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod +x nvim.appimage
RUN ./nvim.appimage --appimage-extract
RUN ln -sf /squashfs-root/usr/bin/nvim /usr/bin/nvim

RUN git clone https://github.com/LazyVim/starter ~/.config/nvim && \
    echo "return { { \"EdenEast/nightfox.nvim\" } }" \
        >> ~/.config/nvim/lua/plugins/plugins.lua && \
    echo "vim.cmd [[colorscheme carbonfox]]" >> ~/.config/nvim/init.lua

RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
RUN tar xf lazygit.tar.gz lazygit
RUN install lazygit /usr/local/bin

RUN git config --global user.email "uzleo_eth@proton.me" && \
    git config --global user.name "uzleo"
