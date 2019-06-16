#!/bin/sh

set -e

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -q
apt-get install -qy docker-ce=5:18.09.1~3-0~ubuntu-bionic
