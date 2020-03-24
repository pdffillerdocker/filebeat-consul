template {
  source = "/etc/filebeat/consul/template.ctmpl"
  destination = "/etc/filebeat/filebeat.yml"
  command = "supervisorctl restart filebeat"
}

template {
  source = "/etc/filebeat/consul/clear.ctmpl"
  destination = "/etc/crontabs/root"
  command = "supervisorctl start cron:crond"
}

template {
  source = "/etc/filebeat/consul/prospectors.ctmpl"
  destination = "/etc/filebeat/prospectors.d/prospectors.yml"
  command = "supervisorctl restart filebeat"
}