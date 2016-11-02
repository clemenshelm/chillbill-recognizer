#!/bin/bash

(aws ecr get-login --region eu-central-1) | /bin/bash

docker build -t recognizer-repo .

docker tag recognizer-repo:latest 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest

docker push 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest
