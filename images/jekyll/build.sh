#!/usr/bin/env bash
curl -L $REPOSITORY_TARBALL_URL > /data/repository.tgz

tar -xzf /data/repository.tgz -C /data/repository --strip-components=1

cd /data/repository

bundle install && bundle exec jekyll build --source /data/repository --destination /data/build && aws s3 sync /data/build $BUCKET_PATH
