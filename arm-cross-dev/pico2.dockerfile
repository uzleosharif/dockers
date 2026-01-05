

# a convenient dockerfile to develop C++ stuff for pico2 board


# Builder stage to build Arm Toolchain for Embedded (ATfE)
FROM ubuntu-dev-base:1.0.0 AS builder

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends meson \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN wget -q https://github.com/arm/arm-toolchain/archive/refs/tags/release-21.1.1-ATfE.tar.gz -O atfe-src.tar.gz \
  && tar -xzf atfe-src.tar.gz --strip-components=1 \
  && rm atfe-src.tar.gz
WORKDIR /src/arm-software/embedded
RUN cmake -B build -S . -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/atfe \
  -DENABLE_QEMU_TESTING=OFF \
  -DLLVM_TARGETS_TO_BUILD="ARM;AArch64" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra" \
  -DLLVM_TOOLCHAIN_LIBRARY_VARIANTS="armv8m.main_hard_fp_unaligned_size;armv8m.main_hard_fp_exn_rtti_unaligned_size" \
  -DLLVM_BUILD_TESTS=OFF \
  -DLLVM_BUILD_DOCS=OFF \
  -DLLVM_BUILD_EXAMPLES=OFF \
  -DCLANG_ENABLE_OBJC_REWRITER=OFF \
  -DLLVM_ENABLE_RUNTIMES= \
  -DLLVM_DISTRIBUTION_COMPONENTS="clang;clang-resource-headers;clangd;clang-tidy;clang-format;lld;llvm-ar;llvm-ranlib;llvm-nm;llvm-objcopy;llvm-strip;llvm-config;llvm-objdump" \
  -DLLVM_TOOLCHAIN_DISTRIBUTION_COMPONENTS="llvm-toolchain-config-files;llvm-toolchain-libs;llvm-toolchain-third-party-licenses" \
  && cmake --build build --target llvm-toolchain \
  && cmake --build build --target install-llvm-toolchain \
  && (find /opt/atfe -type f -executable -exec strip --strip-unneeded {} + || true)

# Final stage
FROM arm-cross-dev-base:1.0.0

COPY --from=builder /opt/atfe/ /opt/atfe/

# use latest codex tool
RUN npm i -g @openai/codex

WORKDIR /opt
RUN \
  git clone --depth 1 https://github.com/uzleosharif/pico-sdk -b master && \
  git clone --depth 1 https://github.com/hathach/tinyusb -b master
