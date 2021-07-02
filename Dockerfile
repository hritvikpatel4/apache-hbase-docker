FROM alpine:latest

LABEL maintainer="Hritvik Patel <hritvik.patel4@gmail.com>"

ARG JAVA_VERSION=8
ARG JAVA_RELEASE=JDK
ARG HBASE_VERSION=2.2.7

RUN set -eux && \
    pkg="openjdk$JAVA_VERSION" && \
    if [ "$JAVA_RELEASE" != "JDK" ]; then \
        pkg="$pkg-jre"; \
    fi && \
    apk add --no-cache $pkg

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PATH $PATH:/hbase/bin
ENV PATH $PATH:$JAVA_HOME/bin

WORKDIR /

RUN set -eux && \
    apk add --no-cache wget tar bash && \
    wget -t 10 --max-redirect 1 --retry-connrefused -O "hbase-$HBASE_VERSION-bin.tar.gz" "https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz" && \
    mkdir "hbase-$HBASE_VERSION" && \
    tar xzf "hbase-$HBASE_VERSION-bin.tar.gz" -C "hbase-$HBASE_VERSION" --strip 1 && \
    test -d "hbase-$HBASE_VERSION" && \
    ln -sv "hbase-$HBASE_VERSION" hbase && \
    rm -fv "hbase-$HBASE_VERSION-bin.tar.gz" && \
    rm -rf hbase/docs hbase/src && \
    mkdir /hbase-data && \
    apk del tar wget

RUN bash -c ' \
    set -euxo pipefail && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache jruby jruby-irb asciidoctor && \
    echo exit | hbase shell \
    # jruby-maven jruby-minitest jruby-rdoc jruby-rake jruby-testunit && \
    '

VOLUME /hbase-data

COPY entrypoint.sh /
COPY conf/hbase-site.xml /hbase/conf/
COPY profile.d/java.sh /etc/profile.d/

# Stargate  8080  / 8085
# Thrift    9090  / 9095
# HMaster   16000 / 16010
# RS        16020 / 16030
EXPOSE 8080 8085 9090 9095 16000 16010 16020 16030

ENTRYPOINT ["/entrypoint.sh"]
