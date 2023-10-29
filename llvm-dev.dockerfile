# This assumes that modercpp-dev.dockerfile has been instantiated as cpp-dev image

FROM cpp-dev

RUN apt update && apt upgrade -y && apt install -y \
    device-tree-compiler zlib1g-dev libedit-dev
