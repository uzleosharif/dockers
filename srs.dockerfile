

   
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
  libfreetype-dev \
  libtool \
  libomp-dev \
  libfontconfig1 \
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
