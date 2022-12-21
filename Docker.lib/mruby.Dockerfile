ENV MRUBY_VERSION 2.0.1
COPY build_config.rb ${BUILDDIR}
RUN apt install -y ruby && \
    cd ${BUILDDIR} && /usr/bin/ruby build_config.rb && \
    install mruby/build/${DEFAULT_DOCKCROSS_IMAGE}/lib/libmruby.a $CROSS_ROOT/lib && \
    cd mruby && \
    make clean