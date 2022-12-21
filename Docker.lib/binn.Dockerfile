RUN cd ${BUILDDIR} && git clone --depth 1 https://github.com/liteserver/binn.git && cd binn && \
    $CC -fPIC -O3 -c src/binn.c && \
    $AR rcs libbinn.a binn.o && \
    install -m644 libbinn.a ${CROSS_ROOT}/lib && \
    cd .. rm binn