#!/bin/bash

set -e

if [[ -z $1 ]]; then
  echo "Must specify root of shwoodard/sw repo as first argument"
  exit 1
fi

app_path=$(cd $1; pwd)
tmpl=$(<./web-server/nginx.conf.tmpl)
out=$(echo $tmpl | sed s%APP_ROOT%$app_path% | sed s%BOOTSTRAP_ROOT%$(pwd)%g)

echo $out > web-server/nginx.conf

echo "nginx.conf writen from template"
