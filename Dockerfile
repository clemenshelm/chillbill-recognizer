# Mostly taken from http://blog.giantswarm.io/getting-started-with-microservices-using-ruby-on-rails-and-docker/
FROM ruby:2.3.1

RUN apt-get update &&  apt-get install -y \
  ghostscript=9.06~dfsg-2+deb8u1 \
  tesseract-ocr=3.03.03-1 \
  tesseract-ocr-deu=3.02-2 

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

ENV APP_HOME /myapp
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Should be RUN bundle install --deployment for production
RUN bundle install

ADD . /myapp