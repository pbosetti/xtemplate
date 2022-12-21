ENV ZMQ_VERSION 4.3.4
RUN cd ${BUILDDIR} && curl -L https://github.com/zeromq/libzmq/releases/download/v${ZMQ_VERSION}/zeromq-${ZMQ_VERSION}.tar.gz | tar xzf - && \
    cd zeromq-${ZMQ_VERSION} && \
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -Bxbuild -H. -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DWITH_DOCS=OFF -DZMQ_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -Cxbuild install -j${NCPUS} && \
    cd .. && rm -rf zeromq-${ZMQ_VERSION}