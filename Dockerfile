FROM ruby:2.7-alpine3.11

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN apk add --no-cache --update build-base sqlite-dev sqlite tzdata

RUN bundle install

COPY . /app
