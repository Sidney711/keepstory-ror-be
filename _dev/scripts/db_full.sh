#!/bin/sh
docker compose exec kinskeeper.rails.web rails db:drop db:create db:migrate db:seed