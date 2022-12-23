ENV LIBUV_VERSION 1.44.2
RUN cd ${BUILDDIR} && \
    curl -L https://github.com/libuv/libuv/archive/refs/tags/v${LIBUV_VERSION}.tar.gz | tar xzf - && \
    cd libuv-${LIBUV_VERSION} && \
    cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DLIBUV_BUILD_BENCH=OFF -DLIBUV_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} && \
    cmake --build build -j${NCPUS} -t install && \
    cd .. && rm -rf libuv-${LIBUV_VERSION} v${LIBUV_VERSION}.tar.gz
