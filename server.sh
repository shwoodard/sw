#!/bin/bash

if [[ -z $1 ]]; then
  echo "Must supply path to static site root as first argument. exiting..."
  exit 1
fi

if [[ -z $PORT ]]; then
  echo "ENV var PORT is required. exiting..."
  exit 1
fi

go_path=${GOPATH:-"$HOME/go"}
repo="github.com/shwoodard/sw"
app_path="$go_path/src/$repo/main.go"

if [[ -f app_path ]]; then
  go get $repo
else
  go get -u $repo
fi

conf_path=$(pwd)/web-server/nginx.conf
nginx_pid_path=/usr/local/var/run/nginx.pid

if [[ -f "$conf_path" ]]; then
  touch ./web-server/logs/error.log
  if [[ -f "$nginx_pid_path" ]]; then
    echo "Nginx is running. reloading config..."
    sudo env PATH=$PATH nginx -s reload
    echo "nginx config reloaded..."
  else
    echo "Nginx is not running. starting..."
    sudo env PATH=$PATH nginx -c $conf_path
    echo "nginx started..."
  fi
else
  echo "nginx.conf does not exit in web-server/. Run nginx-conf.sh? exiting..."
  exit 1
fi

static_site_path=$(cd $1; pwd)
go_pid_path="$(pwd)/var/run/go.pid"
if [[ -f "$go_pid_path" ]]; then
  go_pid=$(< "$go_pid_path")
  go_app_running=$(kill -0 "$go_pid"; echo $?)
  if [ $go_app_running -eq 0 ]; then
    kill "$go_pid"
  fi
  rm "$go_pid_path"
fi

PORT=$PORT nohup "$go_path/bin/sw" -static=$static_site_path > ./log/backend.log &
backend_start_exit_code=$?
if [ $backend_start_exit_code -ne 0 ]; then
  echo "backend failed to start. nginx may still be running. exiting..."
  exit 1
fi

echo $! > $go_pid_path
echo "backend started..."

go_pid=$(< "$go_pid_path")
nginx_pid=$(< "$nginx_pid_path")

trap "kill $go_pid && rm $go_pid_path &> /dev/null" \
  SIGINT SIGTERM

echo "waiting... SIGINT/SIGTERM to stop"
wait $go_pid

