ENV ONIGURUMA_VERSION 6.9.7.1
ENV ONIGURUMA_DIR 6.9.7
RUN cd ${BUILDDIR} && curl -L https://github.com/kkos/oniguruma/releases/download/v${ONIGURUMA_VERSION}/onig-${ONIGURUMA_VERSION}.tar.gz | tar zxf - ; \
    cd onig-${ONIGURUMA_DIR} && \
    cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DBUILD_SHARED_LIBS=OFF -DENABLE_BINARY_COMPATIBLE_POSIX=ON -DENABLE_POSIX_API=ON && \
    cmake --build build -t install -j4 && \
    cd .. && rm -rf ${ONIGURUMA_DIR}