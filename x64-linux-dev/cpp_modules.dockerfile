

FROM cpp-dev-base:25.10

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LLVM_TOOLCHAIN=/opt/llvm \
  PATH=/opt/llvm/bin:${PATH} \
  LD_LIBRARY_PATH=/opt/llvm/lib:/opt/llvm/lib/x86_64-unknown-linux-gnu \
  CC=clang \
  CXX=clang++

# hadolint ignore=DL3008
RUN set -eu; \
  apt-get -qq update; \
  apt-get install --no-install-recommends -qq -y xz-utils; \
  rm -rf /var/lib/apt/lists/*; \
  LLVM_JSON="$(wget --no-check-certificate -qO- https://api.github.com/repos/llvm/llvm-project/releases/latest)"; \
  LLVM_URL="$(printf '%s\n' "${LLVM_JSON}" | jq -r '.assets[] | select(.name | test("^LLVM-[0-9]+\\.[0-9]+\\.[0-9]+-Linux-X64\\.tar\\.xz$")) | .browser_download_url' | head -n1)"; \
  test -n "${LLVM_URL}"; \
  LLVM_TAR="/tmp/$(basename "${LLVM_URL}")"; \
  wget --no-check-certificate -qO "${LLVM_TAR}" "${LLVM_URL}"; \
  mkdir -p "${LLVM_TOOLCHAIN}"; \
  tar -xJf "${LLVM_TAR}" -C "${LLVM_TOOLCHAIN}" --strip-components=1; \
  rm "${LLVM_TAR}"; \
  ln -sf "${LLVM_TOOLCHAIN}/bin/clang" /usr/local/bin/clang; \
  ln -sf "${LLVM_TOOLCHAIN}/bin/clang++" /usr/local/bin/clang++; \
  ln -sf "${LLVM_TOOLCHAIN}/bin/clang" /usr/local/bin/cc; \
  ln -sf "${LLVM_TOOLCHAIN}/bin/clang++" /usr/local/bin/c++; \
  printf '%s\n' "${LLVM_TOOLCHAIN}/lib" "${LLVM_TOOLCHAIN}/lib/x86_64-unknown-linux-gnu" >/etc/ld.so.conf.d/llvm.conf; \
  ldconfig; \
  clang++ --version

# hadolint ignore=DL3003
RUN \
  mkdir -p /modules/bmi/uzleo /modules/lib/uzleo /modules/include/ && \
  # std
  clang++ -stdlib=libc++ -std=c++26 -O3 ${LLVM_TOOLCHAIN}/share/libc++/v1/std.cppm --precompile -o /modules/bmi/std.pcm && \
  clang++ -std=c++26 -stdlib=libc++ -O3 ${LLVM_TOOLCHAIN}/share/libc++/v1/std.compat.cppm --precompile -fmodule-file=std=/modules/bmi/std.pcm -o /modules/bmi/std.compat.pcm && \
  # fmt
  wget --no-check-certificate -q https://github.com/fmtlib/fmt/releases/download/11.1.4/fmt-11.1.4.zip && \
  unzip fmt-11.1.4.zip && \
  cd fmt-11.1.4/ && \
  cp src/fmt.cc src/fmt.cppm && \
  mv include/fmt /modules/include/. && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fPIC -I /modules/include/ src/fmt.cppm -fmodule-output -c -o fmt.o && \
  cp fmt.pcm /modules/bmi/ && \
  clang++ -shared -o libfmt.so fmt.o && \
  cp libfmt.so /modules/lib/ && \
  cd .. && \
  # uzleo.json
  git clone https://github.com/uzleosharif/json-parser.git && \
  cd json-parser && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fPIC src/json.cppm -c -o json.o -fmodule-output -fmodule-file=std=/modules/bmi/std.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm && \
  cp json.pcm /modules/bmi/uzleo/. && \
  clang++ -shared -o libjson.so json.o && \
  cp libjson.so /modules/lib/uzleo/ && \
  cd .. && \
  # modi
  git clone https://github.com/uzleosharif/module-builder.git && \
  cd module-builder/ && \
  git checkout v0.3.0 && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fmodule-file=uzleo.json=/modules/bmi/uzleo/json.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm -fmodule-file=std=/modules/bmi/std.pcm module_builder.cpp -o modi -ljson -lfmt -L /modules/lib/ -L /modules/lib/uzleo && \
  cp modi /usr/bin/. && \
  cd .. && \
  rm -r module-builder
