ENV LIBYAML_VERSION 0.2.2
RUN cd ${BUILDDIR} && curl -L https://github.com/yaml/libyaml/archive/${LIBYAML_VERSION}.tar.gz | tar xzf - && \
    cd libyaml-${LIBYAML_VERSION} && \
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DBUILD_TESTING=OFF _DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DYAML_STATIC_LIB_NAME=yaml -Bxbuild -H. && \
    make -Cxbuild install/strip -j${NCPUS} && \
    cd .. && rm -rf libyaml-${LIBYAML_VERSION}