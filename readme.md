# filebeat-consul
Filebeat configuring via Consul

### Environment Variables
| Name | Description | Default |
|------|-------------|---------|
| SERVICE_KV_PATH | The path to filebeat folder with config KV in consul |"filebeat" |
| CONSUL_TOKEN | The consul acl token. See https://www.consul.io/docs/guides/acl.html#acl-agent-token | |
| CONSUL_HTTP_ADDR | The consul URL | http://172.17.0.1:8500 |
| CLUSTER_NAME | The additional subfolders in KV path for different filebit instances | ecs-cluster |
| SERVICE_ENV | The additional prefix to elasticsearch indexname |stage|

### Mount Points
/var/log/       logs

### Visual diagram
![](https://github.com/pdffillerdocker/filebeat-consul/blob/master/_docs/filebeat.png)

### Configure the cleaner
| Name | Description |
|------|-------------|
| logs_TTL | Time in min. If during the specified time the file is not changed, it is deleted |

### Sample configure cleaner (put consul KV via bash script)
```bash
#!/bin/bash

SERVICE_KV_PATH="filebeat"
CONSUL_SERVER_URL="http://localhost:8500"

curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/config/logs_TTL <<< "180"
```

### Configure the output
| Name | Description |
|------|-------------|
| es_host | The elasticsearch addres |
| es_port | The elasticsearch port |

### Sample configure output (put consul KV via bash script)
```bash
#!/bin/bash

SERVICE_KV_PATH="filebeat"
CONSUL_SERVER_URL="http://localhost:8500"

curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/config/es_host <<< "localhost"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/config/es_port <<< "9200"
```

### Configure inputs
| Name | Description |
|------|-------------|
| doc_type | The value for fileds document_type |
| index_prefix | The elasticsearch index prefix. Result elasticsearch prefix like "SERVICE_ENV-%{[fields.index_prefix]}-%{+yyyy.MM.dd}" |
| json | Boolean value. Set true if log in json format |
| path | The parsing file mask |

### Sample configure inputs (put consul KV via bash script)
```bash
#!/bin/bash

CLUSTER_NAME="ecs-cluster"
SERVICE_KV_PATH="filebeat"
CONSUL_SERVER_URL="http://localhost:8500"

curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-access/doc_type <<< "container-1-nginx-access"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-access/index_prefix <<< "nginx-access"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-access/json <<< "1"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-access/path <<< "/var/log/container_1/nginx/*.json"

curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-error/doc_type <<< "container-1-nginx-error"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-error/index_prefix <<< "nginx-error"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-error/json <<< "0"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-1-nginx-error/path <<< "/var/log/container_1/nginx/*.log"


curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-access/doc_type <<< "container-2-nginx-access"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-access/index_prefix <<< "nginx-access"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-access/json <<< "1"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-access/path <<< "/var/log/container_1/nginx/*.json"

curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-error/doc_type <<< "container-2-nginx-error"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-error/index_prefix <<< "nginx-error"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-error/json <<< "0"
curl -X PUT -d @- ${CONSUL_SERVER_URL}/v1/kv/{SERVICE_KV_PATH}/{CLUSTER_NAME}/container-2-nginx-error/path <<< "/var/log/container_2/nginx/*.log"
```

# sample keys used filebeat-consul
```bash
curl --header "X-Consul-Token: 1234sampletoken" "http://localhost:8500/v1/kv/filebeat?keys"
[
    "filebeat/config/es_host",
    "filebeat/config/es_port",
    "filebeat/config/logs_TTL",

    "filebeat/ecs-cluster/container-1-nginx-access/doc_type",
    "filebeat/ecs-cluster/container-1-nginx-access/index_prefix",
    "filebeat/ecs-cluster/container-1-nginx-access/json",
    "filebeat/ecs-cluster/container-1-nginx-access/path",

    "filebeat/ecs-cluster/container-1-nginx-error/doc_type",
    "filebeat/ecs-cluster/container-1-nginx-error/index_prefix",
    "filebeat/ecs-cluster/container-1-nginx-error/json",
    "filebeat/ecs-cluster/container-1-nginx-error/path",

    "filebeat/ecs-cluster/container-2-nginx-access/doc_type",
    "filebeat/ecs-cluster/container-2-nginx-access/index_prefix",
    "filebeat/ecs-cluster/container-2-nginx-access/json",
    "filebeat/ecs-cluster/container-2-nginx-access/path",

    "filebeat/ecs-cluster/container-2-nginx-error/doc_type",
    "filebeat/ecs-cluster/container-2-nginx-error/index_prefix",
    "filebeat/ecs-cluster/container-2-nginx-error/json",
    "filebeat/ecs-cluster/container-2-nginx-error/path"
]
```

### additional build parameters
| Name | Description | Default |
|------|-------------|---------|
| FILEBEAT_VERSION | The filebeat version | 6.5.4 |
| CONSUL_TEMPLATE_VERSION | The consul-template version | 0.18.1 |
| ALPINE_GLIBC_PACKAGE_VERSION | The glibc version | 2.23-r1 |

### useful links
[Filebeat Reference](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)

[Consul Documentation ](https://www.consul.io/docs/index.html)
