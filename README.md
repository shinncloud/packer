# Packer Builders

## Configure Repository

```
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google https://source.developers.google.com/p/shinncloud/r/packer

```

## Encrypt Buildkite Key

```
export BUILDKITE_KEY=<yourbuildkitekey>
echo -n $BUILDKITE_KEY | gcloud kms encrypt \
  --plaintext-file=- \
  --ciphertext-file=- \
  --location=global \
  --keyring=packer \
  --key=buildkite | base64
```

## Build Image

```
gcloud builds submit --config cloudbuild-builder.yaml --substitutions TAG_NAME=builder-v10
```

Use this `TAG_NAME` when deploying the template with Terraform in the `shared` folder.
