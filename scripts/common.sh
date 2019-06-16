#!/bin/sh

set -e

apt-get update -q
apt-get install -qy apt-transport-https ca-certificates curl software-properties-common python-minimal
