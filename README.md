# Packer Builders

## Bootstrap

```
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google https://source.developers.google.com/p/shinncloud/r/packer

gcloud kms keyrings create packer --location=global
gcloud kms keys create buildkite --location=global --keyring=packer --purpose=encryption
gcloud kms keys add-iam-policy-binding buildkite \
  --location=global \
  --keyring=packer \
  --member=serviceAccount:453728115251@cloudbuild.gserviceaccount.com \
  --role=roles/cloudkms.cryptoKeyDecrypter
gcloud projects add-iam-policy-binding shinncloud \
  --member serviceAccount:453728115251@cloudbuild.gserviceaccount.com \
  --role roles/editor
gcloud source repos create packer



echo -n $BUILDKITE_KEY | gcloud kms encrypt \
  --plaintext-file=- \
  --ciphertext-file=- \
  --location=global \
  --keyring=packer \
  --key=buildkite | base64
