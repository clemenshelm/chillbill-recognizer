# Mostly taken from http://blog.giantswarm.io/getting-started-with-microservices-using-ruby-on-rails-and-docker/
FROM ruby:2.2.2

RUN apt-get update &&  apt-get install -y \
  ghostscript \
  tesseract-ocr \
  tesseract-ocr-deu

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /myapp
WORKDIR /myapp

COPY Gemfile /myapp
COPY Gemfile.lock /myapp

# Should be RUN bundle install --deployment for production
RUN bundle install

COPY . /myapp
