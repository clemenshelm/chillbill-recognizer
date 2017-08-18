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
2. [AWS Set-Up](#aws-set-up)
3. [Docker Set-Up](#docker-set-up)
4. [Running it locally](#running-it-locally)
5. [Testing](#testing)

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

# AWS Set-Up
> You will need AWS permissions and credentials. Have a memory stick ready and ask either @Althaire or @clemenshelm to create your user and give you your credentials

You will need to have AWS Command Line Interface installed. [Here's a guide](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) on how to install it. _You will need `pip` installed. Either `sudo apt get` it or use homebrew._

Once it is installed, run the command `aws configure`. When prompted enter the credentials given to you, enter `eu-central-1` for region and just hit the enter/return key on the last prompt.

Now that your credentials are configured you can get your login:
*On Mac:*
`aws ecr get-login |`

*On Linux*
'aws ecr get-login --no-include-email --region eu-central-1'

# Docker Set-Up
> REMEMBER: If using Ubuntu, all docker commands AND docker compose commands need to be run with sudo!

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
docker-compose run tests rspec ./spec/
```

_Modify the path in the command to choose specific spec files._


# Generating data for machine learning

```shell
sudo docker-compose run ml rake machine_learning:import_bill_data
sudo docker-compose run ml rake machine_learning:add_prices
sudo docker-compose run ml rake machine_learning:list_bills
```
At least on ubuntu, you have to change the ownership of the files the edit them (now the owner is root). After changing the ownership, you have to correct the  yml files.

```shell
sudo docker-compose run ml rake machine_learning:add_dimensions
sudo docker-compose run ml rake machine_learning:generate_csvs
```
