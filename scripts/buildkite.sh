#!/bin/sh

set -e

AGENT_TOKEN="${1:-$AGENT_TOKEN}"
AGENT_VERSION="${2:-$AGENT_VERSION}"
AGENT_TAGS="${3:-$AGENT_TAGS}"

echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
apt-get update -q
apt-get install -qy buildkite-agent="$AGENT_VERSION"
sed -i "s/xxx/$AGENT_TOKEN/g" /etc/buildkite-agent/buildkite-agent.cfg
sed -i "s/%hostname-%n/%hostname/g" /etc/buildkite-agent/buildkite-agent.cfg
usermod -G docker buildkite-agent
systemctl enable buildkite-agent
mkdir -p /etc/systemd/system/buildkite-agent.service.d
cat <<EOF > /etc/systemd/system/buildkite-agent.service.d/env.conf
[Service]
Environment=BUILDKITE_AGENT_TAGS_FROM_GCP=true
Environment=BUILDKITE_AGENT_TAGS="$AGENT_TAGS"
EOF
