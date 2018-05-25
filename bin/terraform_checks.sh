#!/usr/bin/env bash

# Add binaries to bin directory
mkdir -p vendor/bin
export PATH=$PATH:vendor/bin

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform vendor/bin/

terraform fmt
