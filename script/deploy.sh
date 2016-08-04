#!/usr/bin/env bash
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS

export REPO=inf0rmer/pageturner
export TAG=`if [ "$TRAVIS_BRANCH" == "master" ]; then echo "latest"; else echo $TRAVIS_BRANCH ; fi`

docker build -f Dockerfile -t $REPO:$COMMIT .
docker tag -f $REPO:$COMMIT $REPO:$TAG
docker tag $REPO:$COMMIT $REPO:travis-$TRAVIS_BUILD_NUMBER
docker push $REPO
