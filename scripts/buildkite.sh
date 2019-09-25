#!/usr/bin/env bash

set -eo pipefail

export PATH="${PATH}:/snap/bin"

AGENT_TOKEN="${1:-AGENT_TOKEN}"
AGENT_VERSION="${2:-$AGENT_VERSION}"
AGENT_TAGS="${3:-$AGENT_TAGS}"
AGENT_KMS_KEYRING="${4:-AGENT_KMS_KEYRING}"
AGENT_KMS_KEY="${4:-AGENT_KMS_KEY}"
AGENT_KMS_LOCATION="${4:-AGENT_KMS_LOCATION}"

KMS_ARGS=(
  "--location=$AGENT_KMS_LOCATION"
  "--keyring=$AGENT_KMS_KEYRING"
  "--key=$AGENT_KMS_KEY"
)

BUILDKITE_KEY="$(echo -n "$AGENT_TOKEN" | base64 --decode | gcloud kms decrypt --plaintext-file=- --ciphertext-file=- "${KMS_ARGS[@]}")"

echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
apt-get update -q
apt-get install -qy buildkite-agent="$AGENT_VERSION"
sed -i "s/xxx/$BUILDKITE_KEY/g" /etc/buildkite-agent/buildkite-agent.cfg
sed -i "s/%hostname-%n/%hostname/g" /etc/buildkite-agent/buildkite-agent.cfg
usermod -G docker buildkite-agent
systemctl enable buildkite-agent
mkdir -p /etc/systemd/system/buildkite-agent.service.d

cat <<EOF > /etc/systemd/system/buildkite-agent.service.d/env.conf
[Service]
Environment=BUILDKITE_AGENT_TAGS_FROM_GCP=true
Environment=BUILDKITE_AGENT_TAGS="$AGENT_TAGS"
EOF

# Keys
mkdir -p /var/lib/buildkite-agent/.ssh

for key in /tmp/keys/*.enc; do
  gcloud kms decrypt "${KMS_ARGS[@]}" \
    --ciphertext-file="$key" \
    --plaintext-file="/var/lib/buildkite-agent/.ssh/${key%.enc}"
  chmod 600 "/var/lib/buildkite-agent/.ssh/${key%.enc}"
done

mv /tmp/ssh_config /var/lib/buildkite-agent/.ssh/config
chown -R buildkite-agent:buildkite-agent /var/lib/buildkite-agent/.ssh
chmod 700 /var/lib/buildkite-agent/.ssh

# Disable detached head warnings
sudo -H -u buildkite-agent git config --global advice.detachedHead false
