# Add binaries to bin directory
mkdir -p vendor/bin

# Install Ruby Dependencies
gem install bundler

# Install Kitchen dependencies
bundle install --binstubs --jobs=$(nproc --ignore=1) --path=vendor/bundle --retry=3

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
mv terraform vendor/bin/