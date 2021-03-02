#!/bin/bash

set -e

./nginx-conf.sh $1
./nginx-start.sh
