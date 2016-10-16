#!/usr/bin/env bash
curl -L $REPOSITORY_TARBALL_URL > /data/repository.tgz

tar -xzf /data/repository.tgz -C /srv/jekyll --strip-components=1

cd /srv/jekyll

chown -R jekyll /srv/jekyll

bundle install && sudo -u jekyll jekyll build --source /srv/jekyll && aws s3 sync /srv/jekyll/_site $BUCKET_PATH
