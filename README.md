# ChillBill recognizer

To start recognition, you'll have to launch 2 processes:

1. The dispatcher daemon which will take care of starting workers for each incoming bill and communicating back the recoginition result
2. The Sidekiq worker process which will do the heavy lifting of bill recognition.

Starting the dispatcher daemon:

```shell
bundle exec ruby ./daemon.rb
```

Starting the Sidekiq worker process:

```shell
bundle exec sidekiq -r ./sidekiq.rb
```

# Local Set-Up
1. [Installations](#installations)
2. [Docker Set-Up](#docker-set-up)
3. [Running it locally](#running-it-locally)
4. [Testing](#testing)

# Installations
To start things off, you will need [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your machine and this repository cloned locally:
```shell
git clone https://github.com/clemenshelm/chillbill-recognizer.git
```

### MacOS
1. Install [Docker](https://docs.docker.com/docker-for-mac/install/).
The installation will also include docker-compose, which you will need, so for now, you are done with set up!

### Ubuntu

1. Install [Docker](https://docs.docker.com/engine/installation/linux/ubuntu/). _Remember to get the Community Edition (CE)!_
3. Install Docker Compose, [here’s a very good guide](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04).

# Docker Set-Up
_Make sure Docker is running with docker info:_
```shell
docker info
```

First we need to build the image that we will make our containers from. To do this, run
```shell
docker build -t recognizer-repo .
```
This will create an image called recognizer repo built from the Dockerfile in our repository. _This will take a while. Now sounds like a good time for some coffee... ☕️_

Once this is done we can make sure our gems are all up to date. To do this we will start one service and make it run bundle install:

```shell
docker-compose run sidekiq bundle
```

You’re done with installations and set up and should now be able to run, test and work on the recognizer!

# Running it locally

_You'll need two terminal windows open simultaneously to run the `processor` service and `sidekiq` service at the same time._

Run one of these in each window:

```shell
docker-compose run sidekiq
```

```shell
docker-compose run processor
```

# Testing

When running tests will be running the `tests` service from our Docker Compose file. To run our whole test suite use:

```shell
docker-compose run test rspec ./spec/
```

_Modify the path in the command to choose specific spec files._
