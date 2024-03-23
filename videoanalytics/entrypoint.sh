#!/bin/sh

sleep 5

python manage.py migrate
python manage.py createcachetable
python manage.py collectstatic  --noinput
gunicorn backend.wsgi:application --bind 0.0.0.0:8000 -w 6 --timeout 300 #--insecure

exec "$@"
