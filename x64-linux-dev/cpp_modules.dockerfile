

FROM cpp-dev-base:25.10

RUN \
  mkdir -p /modules/bmi/uzleo /modules/lib/uzleo /modules/include/ && \
  # std
  clang++ -stdlib=libc++ -std=c++26 -O3 /usr/lib/llvm-20/share/libc++/v1/std.cppm --precompile -o /modules/bmi/std.pcm && \
  clang++ -std=c++26 -stdlib=libc++ -O3 /usr/lib/llvm-20/share/libc++/v1/std.compat.cppm --precompile -fmodule-file=std=/modules/bmi/std.pcm -o /modules/bmi/std.compat.pcm && \
  # fmt
  wget --no-check-certificate -q https://github.com/fmtlib/fmt/releases/download/11.1.4/fmt-11.1.4.zip && \
  unzip fmt-11.1.4.zip && \
  cd fmt-11.1.4/ && \
  cp src/fmt.cc src/fmt.cppm && \
  mv include/fmt /modules/include/. && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fPIC -I /modules/include/ src/fmt.cppm -fmodule-output -c -o fmt.o && \
  cp fmt.pcm /modules/bmi/ && \
  clang++ -shared -o libfmt.so fmt.o && \
  cp libfmt.so /modules/lib/ && \
  cd .. && \
  # uzleo.json
  git clone https://github.com/uzleosharif/json-parser.git && \
  cd json-parser && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fPIC src/json.cppm -c -o json.o -fmodule-output -fmodule-file=std=/modules/bmi/std.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm && \
  cp json.pcm /modules/bmi/uzleo/. && \
  clang++ -shared -o libjson.so json.o && \
  cp libjson.so /modules/lib/uzleo/ && \
  cd .. && \
  # modi
  git clone https://github.com/uzleosharif/module-builder.git && \
  cd module-builder/ && \
  git checkout v0.2.0 && \
  clang++ -std=c++26 -stdlib=libc++ -O3 -fmodule-file=uzleo.json=/modules/bmi/uzleo/json.pcm -fmodule-file=fmt=/modules/bmi/fmt.pcm -fmodule-file=std=/modules/bmi/std.pcm module_builder.cpp -o modi -ljson -lfmt -L /modules/lib/ -L /modules/lib/uzleo && \
  cp modi /usr/bin/. && \
  cd .. && \
  rm -r module-builder
