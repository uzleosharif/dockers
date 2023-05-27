# ubuntu22.10, cmake, clang, conan, python3, pip

FROM ubuntu:22.10 AS base

# g++,python3 : pre-requisite dependency to compile llvm-project-src codebase
# ninja : needed for building llvm-project from source
# wget : to be able to download stuff over the internet e.g. cmake, llvm-project-src
RUN apt update && apt install -y g++ python3 ninja-build wget

# cmake
# get the latest tarball (pre-built) for built cmake (github) and extract
WORKDIR /opt
RUN mkdir cmake/
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.tar.gz -O - \
        | tar -xz -C cmake/ --strip-components=1
ENV PATH=$PATH:/opt/cmake/bin/
WORKDIR /



# llvm : need to build this from latest source for cutting edge features
RUN mkdir llvm-project/
RUN wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-15.0.6.tar.gz -O - \
        | tar -xz -C llvm-project/ --strip-components=1
WORKDIR /llvm-project/
RUN cmake -S llvm -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/llvm/ \
        -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
        -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_PARALLEL_LINK_JOBS=1 
RUN cmake --build build --target install
WORKDIR /


# cleanup for final image
FROM ubuntu:22.10

# cmake, llvm
COPY --from=base /opt /opt/.
ENV PATH=$PATH:/opt/cmake/bin/:/opt/llvm/bin/

# conan
# python3-pip : needed for installing conan package manager
# pkg-config: conan seems to rely on it natively
RUN apt update && apt install -y python3-pip pkg-config
RUN pip install conan
