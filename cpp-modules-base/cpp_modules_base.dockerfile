

# this is meant to provide:
# - packages needed for nvim (editor)
# - llvm toolchain 
# - install fundamental c++ modules

FROM ubuntu:25.04

RUN \
  apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y \
  fish=4.0.1-1 \
  unzip=6.0-28ubuntu6 \
  git=1:2.48.1-0ubuntu1 \
  ripgrep=14.1.1-1 \
  fd-find=10.2.0-1 \
  locales=2.41-6ubuntu1 \
  build-essential=12.12ubuntu1 \
  clang=1:20.0-63ubuntu1 \
  clangd=1:20.0-63ubuntu1 \
  clang-format=1:20.0-63ubuntu1 \
  libc++-dev=1:20.0-63ubuntu1 \
  libc++abi-dev=1:20.0-63ubuntu1 \
  ninja-build=1.12.1-1 \
  ca-certificates=20241223 \
  curl=8.12.1-3ubuntu1 \
  wget=1.24.5-2ubuntu1 && \
  rm -rf /var/lib/apt/lists/* && \
  locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8

RUN \
  mkdir -p /modules/bmi/uzleo /modules/lib/uzleo /modules/include/ && \
  git config --global user.name "uzleo" && \
  git config --global user.email "uzleo_eth@proton.me" && \
  # std
  clang++ -stdlib=libc++ -std=c++26 -O3 /usr/lib/llvm-20/share/libc++/v1/std.cppm --precompile -o /modules/bmi/std.pcm && \
  clang++ -std=c++26 -stdlib=libc++ -O3 /usr/lib/llvm-20/share/libc++/v1/std.compat.cppm --precompile -fmodule-file=std=/modules/bmi/std.pcm -o /modules/bmi/std.compat.pcm && \
  # fmt
  wget --no-check-certificate -q https://github.com/fmtlib/fmt/releases/download/11.1.4/fmt-11.1.4.zip && \
  unzip fmt-11.1.4.zip && \
  cd fmt-11.1.4/ && \
  cp src/fmt.cc src/fmt.cppm && \
  mv include/fmt /modules/include/. && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -I /modules/include/ src/fmt.cppm -fmodule-output -c -o fmt.o && \
  cp fmt.pcm /modules/bmi/ && \
  ar rcs libfmt.a fmt.o && \
  cp libfmt.a /modules/lib/ && \
  cd .. && \
  rm -r fmt* && \
  # uzleo.json
  git clone --depth=1 https://github.com/uzleosharif/json-parser.git && \
  cd json-parser && \
  clang++ -std=c++26 -stdlib=libc++ -O3 src/json.cppm -c -o json.o -fmodule-output -fmodule-file=std=/modules/bmi/std.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm && \
  cp json.pcm /modules/bmi/uzleo/. && \
  ar rcs libjson.a json.o && \
  cp libjson.a /modules/lib/uzleo/ && \
  cd .. && \
  rm -r json-parser 

RUN \
  # neovim
  wget --no-check-certificate -q https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz && \
  tar zxf nvim-linux-x86_64.tar.gz && \
  ln -sf /nvim-linux-x86_64/bin/nvim /usr/bin/nvim && \
  rm nvim-linux-x86_64.tar.gz && \
  # lazygit
  wget --no-check-certificate -q https://github.com/jesseduffield/lazygit/releases/download/v0.50.0/lazygit_0.50.0_Linux_x86_64.tar.gz && \
  tar zxf lazygit_0.50.0_Linux_x86_64.tar.gz && \
  mv lazygit /usr/bin/. && \
  # modi
  git clone --depth=1 https://github.com/uzleosharif/module-builder.git && \
  cd module-builder/ && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fmodule-file=uzleo.json=/modules/bmi/uzleo/json.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm -fmodule-file=std=/modules/bmi/std.pcm module_builder.cpp -o modi -ljson -lfmt -L /modules/lib/ -L /modules/lib/uzleo && \
  cp modi /usr/bin/. && \
  cd .. && \
  rm -r module-builder 


WORKDIR /work/
