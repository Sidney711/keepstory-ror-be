FROM ruby:3.4.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nano wkhtmltopdf graphviz imagemagick

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app