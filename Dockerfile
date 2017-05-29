# Mostly taken from http://blog.giantswarm.io/getting-started-with-microservices-using-ruby-on-rails-and-docker/
FROM 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-envd:latest

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
