FROM golang:1.14 as builder

MAINTAINER Dmitry Levchenko <levchenko.dmytro@pdffiller.team>

ARG FILEBEAT_VERSION
ENV FILEBEAT_VERSION=${FILEBEAT_VERSION:-"7.8.0"}

RUN go get -v github.com/elastic/beats || true
WORKDIR /go/src/github.com/elastic/beats/filebeat/
RUN git checkout "v$FILEBEAT_VERSION" && \
    GOARCH=arm go build


FROM dnull88/base:alpine-arm
MAINTAINER Dmitry Teikovtsev <teikovtsev.dmitry@pdffiller.team>

ARG BUILD_ID
ARG FILEBEAT_VERSION
ARG CONSUL_TEMPLATE_VERSION
ARG ALPINE_GLIBC_PACKAGE_VERSION

# service environment
ENV BUILD_ID=${BUILD_ID:-"1"} \
    SERVICE_KV_PATH="filebeat" \
    CLUSTER_NAME="ecs-cluster" \
    CONSUL_HTTP_ADDR="172.17.0.1:8500" \
    SERVICE_ENV="stage"

# utilites version
ENV CONSUL_VERSION=${CONSUL_TEMPLATE_VERSION:-"0.18.1"} \
    ALPINE_GLIBC_PACKAGE_VERSION=${ALPINE_GLIBC_PACKAGE_VERSION:-"2.27-r0"} \
    ALPINE_GLIBC_BASE_URL="https://github.com/yangxuan8282/alpine-pkg-glibc/releases/download" \
    FILEBEAT_BASE_URL="https://artifacts.elastic.co/downloads/beats/filebeat" \
    CONSUL_BASE_URL="https://releases.hashicorp.com/consul-template"

# install filebeat
ADD . /etc/filebeat/
ENV ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-${ALPINE_GLIBC_PACKAGE_VERSION}.apk" \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-${ALPINE_GLIBC_PACKAGE_VERSION}.apk" \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-${ALPINE_GLIBC_PACKAGE_VERSION}.apk"
RUN set -ex  && apk --no-cache add --virtual .build-dependencies wget ca-certificates  && \
    wget "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_BASE_PACKAGE_FILENAME}" \
    "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_BIN_PACKAGE_FILENAME}" \
    "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_I18N_PACKAGE_FILENAME}" && \
    apk add --no-cache --allow-untrusted "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
    && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && apk del glibc-i18n && \
    apk del .build-dependencies && rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

#COPY filebeat /etc/filebeat/
COPY --from=builder /go/src/github.com/elastic/beats/filebeat/filebeat /etc/filebeat/

RUN ln -s /etc/filebeat/filebeat /usr/local/bin/filebeat && \
    chmod +x /etc/filebeat/provision/*.sh

# install consul-template
RUN wget "${CONSUL_BASE_URL}/${CONSUL_VERSION}/consul-template_${CONSUL_VERSION}_linux_arm.zip" \
    -O /tmp/consul-template.zip && \
    cd /tmp && unzip consul-template.zip && \
    mv /tmp/consul-template /usr/local/bin/consul-template && \
    chmod +x /usr/local/bin/consul-template

# prepare supervisor
RUN mv /etc/filebeat/supervisor/*.conf /opt/docker/etc/supervisor.d/ && \
    rm /opt/docker/etc/supervisor.d/dnsmasq.conf && \
    rm /opt/docker/etc/supervisor.d/ssh.conf && \
    rm /opt/docker/etc/supervisor.d/postfix.conf && \
    rm /opt/docker/etc/supervisor.d/syslog.conf