


FROM ubuntu-dev-base:25.10

RUN \
  apt-get -qq update && apt-get upgrade -qq -y && \
  apt-get install --no-install-recommends -qq -y \
  doxygen \
  gdb \
  libclang-rt-20-dev && \
  rm -rf /var/lib/apt/lists/*

