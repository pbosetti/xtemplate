ENV OPENBLAS_VERSION 0.3.6
RUN cd ${BUILDDIR} && curl -L https://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz | tar xzf - && \
    cd OpenBLAS-${OPENBLAS_VERSION} &&\
    cmake -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DCMAKE_BUILD_TYPE=Release -Bxbuild -H. && \
    cmake --build xbuild -t install -j${NCPUS} && \
    cd .. && rm -rf OpenBLAS-${OPENBLAS_VERSION}