FROM ruby:2.2.2

ENV LANG="C.UTF-8"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# update stuff
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# bundle in cache for faster builds
# see also: http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir /app
WORKDIR /app
ADD . /app
