#!/bin/sh
docker compose exec keepstory.rails.web rails db:drop db:create db:migrate db:seed