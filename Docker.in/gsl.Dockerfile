ENV GSL_VERSION 2.7
RUN cd ${BUILDDIR} && \
    curl -L https://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz | tar xzf - && \
    cd gsl-${GSL_VERSION} && \
    ./configure --prefix=${CROSS_ROOT} --disable-shared --enable-static --host=$CROSS_TRIPLE && \
    make -j${NCPUS} && make install && \
    cd .. && rm -rf gsl-${GSL_VERSION}