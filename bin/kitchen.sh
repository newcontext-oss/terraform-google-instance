#!/usr/bin/env bash

# Decrypt sensitive files
#XXX even encrypted, this is risky IF PRs are allowed to kick off builds
openssl aes-256-cbc -K $encrypted_cfdeb2eb7efd_key -iv $encrypted_cfdeb2eb7efd_iv -in ci.tar.gz.enc -out ci.tar.gz -d

# Decompress sensitive files
tar -zxf ci.tar.gz
rm ci.tar.gz
#export GCLOUD_PROJECT=$(jq -r '.project_id' credentials.json)
#export TF_VAR_gcloud_project=$GCLOUD_PROJECT

# Add binaries to bin directory
mkdir -p vendor/bin
export PATH=$PATH:vendor/bin:vendor/google-cloud-sdk/bin

# Install gcloud command line client
wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-202.0.0-linux-x86_64.tar.gz
tar -zxf google-cloud-sdk-*-linux-x86_64.tar.gz -C vendor
rm google-cloud-sdk-*-linux-x86_64.tar.gz
./vendor/google-cloud-sdk/install.sh -q

# Authenticate using the credentials.json
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/credentials.json"
gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project "$GCLOUD_PROJECT"
gcloud config set compute/zone us-west1-a

source .env

yes | ssh-keygen -f ubuntu -N '' >/dev/null

my_public_ip=\$(dig +short myip.opendns.com @resolver1.opendns.com)
export TF_VAR_engineer_cidrs="[\"$my_public_ip/32\"]"
export TF_VAR_gcloud_project="$GCLOUD_PROJECT"
export TF_VAR_ssh_key="$(pwd)/ubuntu.pub"


bundle exec kitchen test --destroy always
KITCHEN_EXIT_CODE=$?

# cleanup
rm -Rf credentials.json .env ubuntu*

exit $KITCHEN_EXIT_CODE
