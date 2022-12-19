RUN cd ${BUILDDIR} && \
    git clone --depth 1 https://github.com/osrf/bzip2_cmake.git &&\
    cd bzip2_cmake &&\
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DCMAKE_BUILD_TYPE=Release -Bbuild && \
    cmake --build build -t install -j${NCPUS} &&\
    cd .. && rm -rf bzip2_cmake