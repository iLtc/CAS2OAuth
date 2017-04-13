#!/bin/sh

cd /usr/src/app

rm /usr/src/app/tmp/pids/server.pid

bin/rails db:migrate RAILS_ENV=development

rails server -b 0.0.0.0
