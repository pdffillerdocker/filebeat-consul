#!/bin/sh

sed -i "s|SERVICE_KV_PATH|${SERVICE_KV_PATH}|g"  /etc/filebeat/consul/clear.ctmpl

sed -i "s|SERVICE_KV_PATH|${SERVICE_KV_PATH}|g"  /etc/filebeat/consul/prospectors.ctmpl
sed -i "s|CLUSTER_NAME|${CLUSTER_NAME}|g"        /etc/filebeat/consul/prospectors.ctmpl

sed -i "s|CLUSTER_NAME|${CLUSTER_NAME}|g"        /etc/filebeat/consul/template.ctmpl
sed -i "s|SERVICE_ENV|${SERVICE_ENV}|g"          /etc/filebeat/consul/template.ctmpl
sed -i "s|SERVICE_KV_PATH|${SERVICE_KV_PATH}|g"  /etc/filebeat/consul/template.ctmpl

/usr/local/bin/consul-template --log-level=debug --consul-addr=${CONSUL_HTTP_ADDR} -config=/etc/filebeat/consul/consul.hcl
