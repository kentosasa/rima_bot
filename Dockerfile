FROM ruby:2.3.0

ENV APP_ROOT /rima

RUN apt-get update -qq && apt-get install -y nodejs build-essential libpq-dev postgresql-client

RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile ${APP_ROOT}/Gemfile
ADD Gemfile.lock ${APP_ROOT}/Gemfile.lock
RUN bundle install

ADD . $APP_ROOT

~
