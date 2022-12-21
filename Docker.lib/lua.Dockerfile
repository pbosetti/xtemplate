ENV LUA_VERSION 5.4.4
RUN cd ${BUILDDIR} && curl -L https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz | \
    tar xzf - && cd lua-${LUA_VERSION}  && \ 
    make linux CC=$CC AR="${AR} rcu" MYCFLAGS="-fPIC -I${CROSS_ROOT}/include" MYLDFLAGS="-L${CROSS_ROOT}/lib -lncurses" -j${NCPUS} && \
    cd src && install -m 0644 liblua.a ${CROSS_ROOT}/lib && \
    install -m 0644 lua.h luaconf.h lualib.h lauxlib.h lua.hpp ${CROSS_ROOT}/include && \
    cd ../.. && rm -rf lua-${LUA_VERSION}