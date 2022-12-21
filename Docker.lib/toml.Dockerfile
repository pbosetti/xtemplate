ENV TOMLPLUSPLUS_VERSION 3.2.0
RUN git clone --depth 1 https://github.com/cktan/tomlc99.git && \
    cd tomlc99 && \
    make && make prefix=$CROSS_ROOT install && \
    cd .. && rm -rf tomlc99 && \
    curl -L https://github.com/marzer/tomlplusplus/archive/refs/tags/v${TOMLPLUSPLUS_VERSION}.tar.gz | tar xzf - && \
    cd tomlplusplus-${TOMLPLUSPLUS_VERSION} && \
    cmake -DCMAKE_BUILD_TYPE=Release -Bbuild -DCMAKE_INSTALL_PREFIX=$CROSS_ROOT && \
    cmake --build build -t install && \
    cd .. && rm -rf tomlplusplus-${TOMLPLUSPLUS_VERSION}
