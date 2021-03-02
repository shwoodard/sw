#!/bin/bash

set -e

conf_path=$(pwd)/web-server/nginx.conf

go_path=${GOPATH:-"$HOME/go"}
repo="github.com/shwodard/sw"
app_path="$go_path/src/$repo/main.go"

if [[ ! -f app_path ]]; then
  go get -u $repo
fi

PORT=$PORT go run $app_path

if [[ -f "$f" ]]; then
  touch ./web-server/logs/error.log
  sudo env PATH=$PATH nginx -c $conf_path
else
  echo "nginx.conf does not exit in web-server/. Run nginx-conf.sh?"
  exit 1
fi

echo "nginx started"
