#!/usr/bin/env bash

# Decompress sensitive files
tar -zxf ci.tar.gz

# Install gems for Kitchen-Terraform
bundle install --binstubs --jobs=$(nproc --ignore=1) --path=vendor/bundle --retry=3

# Add binaries to bin directory
mkdir -p bin;
export PATH=$PATH:bin:google-cloud-sdk/bin

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform bin/

# Install gcloud command line client
wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-202.0.0-linux-x86_64.tar.gz
tar -zxf google-cloud-sdk-*-linux-x86_64.tar.gz
rm google-cloud-sdk-*-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh -q

# Authenticate using the credentials.json
gcloud auth activate-service-account --key-file credentials.json
gcloud config set project $(jq -r '.project_id' credentials.json)

# For the tests, create a ephemeral ssh key
yes | ssh-keygen -f ubuntu -N '' >/dev/null
