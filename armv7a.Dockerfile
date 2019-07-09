FROM dockcross/linux-armv7a:latest
LABEL maintainer="Paolo Bosetti <paolo.bosetti@unitn.it>"

ENV WORKDIR /work
ENV BUILDDIR /build
ENV DEFAULT_DOCKCROSS_IMAGE armv7a
# build with: docker build -t armv7a .
# then:       docker run --rm armv7a > armv7a && chmod a+x armv7a

# OpenSSL
# Needed by mosquitto and mongodb
RUN mkdir /build
RUN cd ${BUILDDIR} && wget https://launchpad.net/openssl-cmake/1.0.1e/1.0.1e-1/+download/openssl-cmake-1.0.1e-src.tar.gz && \
    tar xf openssl-cmake-1.0.1e-src.tar.gz && \
    cd openssl-cmake-1.0.1e-src && \
    cmake -Bxbuild -H. -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -DBUILD_SHARED_LIBS=ON && \
    make -Cxbuild CFLAGS=-D_POSIX_C_SOURCE=1 install

# libmosquitto
# See https://mosquitto.org/api/files/mosquitto-h.html
ENV MQTT_VERSION 1.5.1
RUN cd ${BUILDDIR} && wget https://github.com/eclipse/mosquitto/archive/v${MQTT_VERSION}.tar.gz && tar xvf v${MQTT_VERSION}.tar.gz && cd mosquitto-${MQTT_VERSION} && \
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake -DDOCUMENTATION=OFF -DWITH_STATIC_LIBRARIES=ON -DWITH_PIC=ON -DCMAKE_INSTALL_PREFIX=${CROSS_ROOT} -Bxbuild -H. && \
    make -Cxbuild CFLAGS=-D_POSIX_C_SOURCE=1 install

# ncurses
# needed by readline
RUN cd ${BUILDDIR} && curl https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz |\
    tar xzf - && cd ncurses-6.1 && \
    ./configure CC=$CC --prefix=$CROSS_ROOT/ --with-build-cc=cc --host=$CROSS_TRIPLE --with-shared --without-normal --without-debug --without-progs --without-ada --without-manpages --without-tests --with-build-cflags="-fPIC"  --with-build-cppflags="-fPIC" && \
    make && make install && make clean

# readline
# needed by lua REPL
RUN cd ${BUILDDIR} && curl https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz | \
    tar xzf - && cd readline-8.0 && \
    ./configure --host=${CROSS_TRIPLE} --prefix=${CROSS_ROOT} --with-curses && \
    make && make install && make clean

# Lua lubrary and REPL
RUN cd ${BUILDDIR} && curl https://www.lua.org/ftp/lua-5.3.5.tar.gz | \
    tar xzf - && cd lua-5.3.5  && \ 
    # make generic CC=$CC AR="${AR} rcu" MYCFLAGS="-fPIC -I${CROSS_ROOT}/include -DLUA_USE_DLOPEN -DLUA_USE_POSIX" MYLIBS="-ldl" && \
    make linux CC=$CC AR="${AR} rcu" MYCFLAGS="-fPIC -I${CROSS_ROOT}/include" MYLDFLAGS="-L${CROSS_ROOT}/lib -lncurses" && \
    cd src && install -m 0644 liblua.a ${CROSS_ROOT}/lib && \
    install -m 0644 lua.h luaconf.h lualib.h lauxlib.h lua.hpp ${CROSS_ROOT}/include

# Cleanup build dir
#RUN rm -rf ${BUILDDIR}/*
