#!/usr/bin/env bash

# Decompress sensitive files
tar -zxf ci.tar.gz

# Add binaries to bin directory
mkdir -p bin;
export PATH=$PATH:bin

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform bin/

yes | ssh-keygen -f ubuntu -N '' >/dev/null

terraform fmt
terraform validate
