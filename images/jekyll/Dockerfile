FROM jekyll/jekyll:3.2

ENV BUILD_PACKAGES curl-dev ruby-dev build-base libffi-dev

RUN apk update && apk upgrade
RUN apk add --no-cache bash gettext python groff less jq py-pip curl tar $BUILD_PACKAGES
RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates
RUN pip install awscli

ADD ./build.sh /usr/local/bin/build

RUN mkdir -p /data/repository
RUN mkdir -p /data/build
RUN chmod 777 /data/build
RUN chmod 777 /data/repository

CMD ["build"]
