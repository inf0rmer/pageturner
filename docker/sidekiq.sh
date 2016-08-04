#!/bin/sh
cd /home/app/builder && bundle exec sidekiq -r ./jobs.rb
