#!/bin/bash

# This scripts waits for the API server to be ready before running functional tests with Behave
# when invoked with parameters, they are used as tagged to be passed to behave
# It allows running tests with specific tags


until curl --location --silent "http://server:5000/isalive" > /dev/null 2>&1; do
  >&2 echo "server is not ready - sleeping"
  sleep 1
done

>&2 echo "server is up - starting tests"

tags="--tags=-wip"

behave $tags --no-skipped --quiet
#--no-color
