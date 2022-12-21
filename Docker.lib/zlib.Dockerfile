ENV ZLIB_VERSION 1.2.13
RUN cd ${BUILDDIR} && \
    curl -L https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz | tar xzf - && \
    cd zlib-${ZLIB_VERSION} && \
    ./configure --prefix=${CROSS_ROOT} && \
    make -j${NCPUS} && make install && \
    cd .. && rm -rf zlib-${ZLIB_VERSION}

