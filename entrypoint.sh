#!/usr/bin/env bash

set -euo pipefail

if [[ $1 == "docker-start" ]]; then
  shift

  if [[ $1 == "gunicorn" ]]; then
    exec gunicorn django_template.wsgi:application
  fi
fi

exec "$@"
