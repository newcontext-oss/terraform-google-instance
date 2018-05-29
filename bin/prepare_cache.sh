#!/usr/bin/env bash

mkdir -p vendor/bin

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform vendor/bin/