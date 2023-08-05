FROM nvim-ub

RUN apt update && apt upgrade -y && apt install -y \
    g++-13 clang-16 cmake ninja-build pkg-config \
    libc++-16-dev libc++abi-16-dev cmake-curses-gui \
    python3-full python3-venv file

RUN python3 -m venv venv && . /venv/bin/activate && pip install conan && \
    pip install cmakelang

RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /venv/bin/conan /usr/bin/conan && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-16 60 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/gcc-13 30
