FROM ruby:2.3.1-alpine

RUN apk add --update git curl g++ musl-dev make && rm -rf /var/cache/apk/*

ADD . /opt/ernest/router-deleter-vcloud-connector
WORKDIR /opt/ernest/router-deleter-vcloud-connector

RUN curl https://s3-eu-west-1.amazonaws.com/ernest-tools/bash-nats -o /bin/bash-nats && chmod +x /bin/bash-nats
RUN ruby -S bundle install

ENTRYPOINT ./run.sh
