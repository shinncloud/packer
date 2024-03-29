#!/bin/sh

set -e

GOSS_VERSION="${1:-v0.3.7}"

curl -L https://github.com/aelsabbahy/goss/releases/download/$GOSS_VERSION/goss-linux-amd64 -o /usr/local/bin/goss
chmod +rx /usr/local/bin/goss
systemctl daemon-reload
systemctl enable goss
