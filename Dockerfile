# Mostly taken from http://blog.giantswarm.io/getting-started-with-microservices-using-ruby-on-rails-and-docker/
FROM ruby:2.3.1

RUN apt-get update &&  apt-get install -y ghostscript g++ autoconf automake libtool autoconf-archive pkg-config libpng12-dev libjpeg62-turbo-dev libtiff5-dev zlib1g-dev libleptonica-dev && git clone https://github.com/DanBloomberg/leptonica.git && cd leptonica && mkdir m4 && autoreconf -vi && ./autobuild && ./configure && make && make install && git clone --depth 1 https://github.com/tesseract-ocr/tesseract.git && cd tesseract && ./autogen.sh && ./configure --enable-debug && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && make install && ldconfig

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
