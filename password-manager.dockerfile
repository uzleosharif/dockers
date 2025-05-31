


# first build docker image `cpp-modules-base` in your system
# using cpp-modules-base/cpp_modules_base.dockerfile


FROM cpp-modules-base

RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y \
  libsodium-dev=1.0.18-1build3
