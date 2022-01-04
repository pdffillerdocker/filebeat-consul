FROM alpine:3.15.0
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
ENV FILEBEAT_VERSION=${FILEBEAT_VERSION:-"6.7.1"} \
    CONSUL_VERSION=${CONSUL_TEMPLATE_VERSION:-"0.22.0"} \
    ALPINE_GLIBC_PACKAGE_VERSION=${ALPINE_GLIBC_PACKAGE_VERSION:-"2.23-r1"} \
    FILEBEAT_BASE_URL="https://artifacts.elastic.co/downloads/beats/filebeat" \
    CONSUL_BASE_URL="https://releases.hashicorp.com/consul-template"

# install filebeat
ADD . /etc/filebeat/
RUN set -ex  && apk --no-cache add --virtual .build-dependencies wget ca-certificates  && \
    apk add --no-cache supervisor gcompat && \
    wget "${FILEBEAT_BASE_URL}/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz" \
    -O /tmp/filebeat.tar.gz && \
    cd /tmp && tar xzvf filebeat.tar.gz && \
    cd filebeat-* && rm *.txt && rm *.md && cp -r * /etc/filebeat/ && \
    cd /tmp && rm -rf filebeat* && \
    ln -s /etc/filebeat/filebeat /usr/local/bin/filebeat && \
    chmod +x /etc/filebeat/provision/*.sh && \
    wget "${CONSUL_BASE_URL}/${CONSUL_VERSION}/consul-template_${CONSUL_VERSION}_linux_amd64.zip" \
    -O /tmp/consul-template.zip && \
    cd /tmp && unzip consul-template.zip && \
    mv /tmp/consul-template /usr/local/bin/consul-template && \
    chmod +x /usr/local/bin/consul-template && \
    apk del .build-dependencies

# prepare supervisor
RUN mkdir -p /var/log/supervisor/ /etc/supervisor.d/ && \
    mv /etc/filebeat/supervisor/*.conf  /etc/supervisor.d/ && \
    mv /etc/filebeat/supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["supervisord"]
