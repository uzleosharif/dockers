


# NOTE: first build docker image `cpp-modules-base:v1.0.0` in your system
# using cpp-modules-base/cpp_modules_base.dockerfile


FROM cpp-modules-base:v1.0.0

RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y \
  cmake=3.31.6-1ubuntu1 \
  libsodium-dev=1.0.18-1build3 && \
  rm -rf /var/lib/apt/lists/*

RUN \
  wget --no-check-certificate -q https://github.com/catchorg/Catch2/archive/refs/tags/v3.8.1.tar.gz && \
  tar zxf v3.8.1.tar.gz && \
  cd Catch2-3.8.1 && \
  cmake -B build -S . -DCMAKE_CXX_COMPILER="clang++" -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DCMAKE_BUILD_TYPE="Release" -G "Ninja" && \
  cmake --build build > /dev/null && \
  cmake --install build > /dev/null && \
  cd .. && \
  rm -rf Catch2-3.8.1 v3.8.1.tar.gz

