
# Assumes you have already run
#  git clone https://github.com/newcontext-oss/terraform-google-instance.git
# such that the directory terraform-google-instance is a child of
# the current directory.

# Modify these to your liking
TF_BIN_LOCATION=/usr/local/bin
GCLOUD_REGION="us-west1"
GCLOUD_ZONE="${GCLOUD_REGION}-a"
GOOGLE_CREDS="$(pwd)/credentials.json"

UBUN_VERSION=$(grep '^VERSION=' /etc/os-release|  \
     sed -E 's/VERSION="([0-9][0-9]*\.[0-9][0-9]*).*".*$/\1/')
UBUN_MAJOR_VERSION=$(echo "$UBUN_VERSION"| sed 's/\.[0-9][0-9]*//')

sudo apt install -y ruby ruby-dev bundler jq

latest_tf=$(curl -s https://www.terraform.io/downloads.html| \
  grep -i linux_amd64|sed 's/^.*<a href="//; s/".*$//')
curl -s "$latest_tf" > tf.zip
unzip tf.zip
sudo mv terraform "$TF_BIN_LOCATION"
rm tf.zip

# chefdk only available for LTS releases of Ubuntu. 
# If we don't have an exact match, then match the major version
CHEF_UBUN_VERSIONS=$(curl -s https://downloads.chef.io/chefdk |  \
    awk '{gsub("><", ">\n<"); print}' |                          \
    grep -E 'Ubuntu [0-9]+\.[0-9]+'|                             \
    sed 's/^.*Ubuntu \([0-9][0-9]*\.[0-9][0-9]*\).*$/\1/')
echo $CHEF_UBUN_VERSIONS|grep -q "${UBUN_VERSION}"
if [ $? -eq 1 ]; then  # no exact match, try major version
    CHEF_VERSION=$(echo "$CHEF_UBUN_VERSIONS" |  \
      tr ' ' '\n'|grep "$UBUN_MAJOR_VERSION")
    if [ -z "$CHEF_VERSION" ]; then
        echo "Error, unable to find a ChefDK version matching"
        echo "the Ubuntu version $UBUN_VERSION or even major"
        echo "version $UBUN_MAJOR_VERSION"
        exit 1
    fi
else
    CHEF_VERSION="$UBUN_VERSION"
fi
CHEF_URL=$(curl -s https://downloads.chef.io/chefdk |   \
    awk '{gsub("><", ">\n<"); gsub("&#x2F;","/"); print}' |  \
    grep "download.*$ss"|sed 's/^.*href="//;s/">Down.*//;')
FILE_NAME=$(basename "$CHEF_URL")
curl "$CHEF_URL" -o "$FILE_NAME"
sudo dpkg -i "$FILE_NAME"


cd terraform-google-instance
echo "Now go to the Google IAM Console and retrieve the credentials"
echo "of a service account which can create Google cloud instances."
echo "Save the credentials (as JSON) in:"
echo "  $GOOGLE_CREDS"

initial=1
seconds=0
while [ ! -f "$GOOGLE_CREDS" ];do
    if [ $initial -eq 1 ]; then
        initial=0
    else
        echo -en "\rwaiting for credentials $seconds seconds" 
    sleep 10
    (( seconds += 10 ))
done


gcloud_project=$(jq -r '.project_id' $GOOGLE_CREDS)
gcloud auth activate-service-account --key-file $GOOGLE_CREDS
gcloud config set project $gcloud_project
gcloud config set compute/zone $GCLOUD_ZONE

cat > .env <<HEREDOC
export GOOGLE_APPLICATION_CREDENTIALS="'$GOOGLE_CREDS'"
export GCLOUD_PROJECT="'$gcloud_project'"
export GCLOUD_REGION="'$GCLOUD_REGION'"
my_public_ip=\$(dig +short myip.opendns.com @resolver1.opendns.com)
export TF_VAR_engineer_cidrs="[\"\$my_public_ip/32\"]"
export TF_VAR_gcloud_project=$GCLOUD_PROJECT
export TF_VAR_ssh_key="$(pwd)/ubuntu.pub"
HEREDOC

yes | ssh-keygen -f ubuntu -N '' >/dev/null
ln ubuntu.pub test/fixtures/tf_module/
bundle install --path gems  # install all dependencies

echo "All set to run some interactive commands. First run:"
echo "    . .env"
echo "Next, execute the configuration to create a Google cloud"
echo "instance with this command:"
echo "    bundle exec kitchen converge"
echo "And then you can run the InSpec tests with this command:"
echo "    bundle exec kitchen verify"
echo "You can clean things up via this command:"
echo "    bundle exec kitchen destroy"
