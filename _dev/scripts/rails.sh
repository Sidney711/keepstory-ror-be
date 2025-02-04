#!/bin/sh

BASE_CMD="docker compose exec kinskeeper.rails.web rails"

if [ $# -eq 0 ]
then
  exit 1
else
  eval "$BASE_CMD $@"
fi