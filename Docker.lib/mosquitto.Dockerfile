# See https://mosquitto.org/api/files/mosquitto-h.html
ENV MQTT_VERSION 2.0.14
RUN cd ${BUILDDIR} && curl -L https://github.com/eclipse/mosquitto/archive/v${MQTT_VERSION}.tar.gz | tar xzf - && \ 
    cd mosquitto-${MQTT_VERSION} && \
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DDOCUMENTATION=OFF -DWITH_STATIC_LIBRARIES=ON -DWITH_PIC=ON -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DCMAKE_BUILD_TYPE=Release -Bxbuild -H. && \
    make -Cxbuild CFLAGS=-D_POSIX_C_SOURCE=1 install -j${NCPUS} && \
    cd .. && rm -rf mosquitto-${MQTT_VERSION}