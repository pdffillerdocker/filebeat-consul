#!/bin/sh

echo "Filebeat starting with correct settings..."
supervisorctl restart filebeat
supervisorctl start cron:crond
