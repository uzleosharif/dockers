

   
FROM cpp-dev-base:25.10

RUN \
  apt-get -qq update && apt-get upgrade -qq -y && \
  apt-get install --no-install-recommends -qq -y \
  patch \
  freeglut3-dev \
  autoconf \
  automake \
  libpthread-stubs0-dev \
  libnss3 \
  libnspr4 \
  libdbus-1-3 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxfixes3 \
  libxrender1 \
  libxtst6 \
  libgl-dev \
  libgl1-mesa-dev \
  libegl-dev \
  libegl1-mesa-dev \
  libsm-dev \
  libibverbs-dev \
  libxml2-dev \
  libtool \
  libomp-dev \
  libfontconfig1 \
  libsuitesparse-dev \
  libsuperlu-dev \
  libblas-dev \
  liblapack-dev \
  libeigen3-dev \
  libharfbuzz-dev \
  libpng-dev \
  libbz2-dev \
  libbrotli-dev \
  libgoogle-glog-dev \
  libgflags-dev \
  libsuitesparse-dev \
  libsuperlu-dev \
  libboost-dev \
  libsparsehash-dev \
  libadolc-dev \
  libmpfr-dev \
  libfftw3-dev \
  libblas-dev \
  liblapack-dev \
  bison \
  flex \
  tcl && \
  rm -rf /var/lib/apt/lists/*

RUN \
  ln -s /usr/lib/x86_64-linux-gnu/libEGL.so.1 /lib64/libEGL.so && \
  ln -s /usr/lib/x86_64-linux-gnu/libGL.so.1 /lib64/libGL.so

RUN \
  cd /tmp && \
  wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz && \
  tar -xvf Python-2.7.18.tar.xz && \
  cd Python-2.7.18 && \
  CC="gcc -std=gnu89" CXX="g++ -std=c++17" ./configure --with-cxx-main && \
  make -j16 && \
  make altinstall && \
  cd -

# install copilot
RUN \
  npm install -g @github/copilot

# SRS needs freetype v2.13.2 because modern versions than introduce breaking changes 
# to one of our packages (EP_FTGL) hence we build it specifically from source rather 
# than apt getting it (v2.13.3 in ubuntu 25.10)
WORKDIR /tmp
RUN wget -O freetype.tar.xz https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz \
 && tar -xf freetype.tar.xz

WORKDIR /tmp/freetype-2.13.2
RUN cmake -S . -B build \
      -DCMAKE_BUILD_TYPE=Release \
 && cmake --build build -j"$(nproc)" \
 && cmake --install build
