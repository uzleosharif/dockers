
# we derive from `dockers/base/ubuntu_dev_base.dockerfile`
FROM ubuntu-dev-base:25.10

# hadolint ignore=DL3008
RUN \
  apt-get -qq update && apt-get upgrade -qq -y && \
  apt-get install --no-install-recommends -qq -y \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  libnewlib-arm-none-eabi \
  libnewlib-dev && \
  rm -rf /var/lib/apt/lists/* 

