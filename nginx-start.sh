#!/bin/bash

set -e

f=$(pwd)/web-server/nginx.conf

if [[ -f "$f" ]]; then
  touch ./web-server/logs/error.log
  sudo env PATH=$PATH nginx -c $f
else
  echo "nginx.conf does not exit in web-server/. Run nginx-conf.sh?"
  exit 1
fi

echo "nginx started"
