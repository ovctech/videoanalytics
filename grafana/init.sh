#!/bin/bash
sleep 10
curl -X POST -H "Content-Type: application/json" -d @celery-monitoring-grafana-dashboard.json http://admin:password@grafana:3000/api/dashboards/db
