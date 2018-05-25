#!/usr/bin/env bash

# Decompress sensitive files
tar -zxf ci.tar.gz

# Add binaries to bin directory
mkdir -p vendor/bin
export PATH=$PATH:vendor/bin:vendor/google-cloud-sdk/bin

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform vendor/bin/

# Install gcloud command line client
wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-202.0.0-linux-x86_64.tar.gz
tar -zxf google-cloud-sdk-*-linux-x86_64.tar.gz -C vendor
rm google-cloud-sdk-*-linux-x86_64.tar.gz
./vendor/google-cloud-sdk/install.sh -q

# Authenticate using the credentials.json
gcloud auth activate-service-account --key-file credentials.json
gcloud config set project $(jq -r '.project_id' credentials.json)

# For the tests, create a ephemeral ssh key
yes | ssh-keygen -f ubuntu -N '' >/dev/null

source .env
kitchen test --destroy always
