#!/bin/bash

echo "Updating apt-get as sudo to stop errors.";
# Updating apt-get to remove Git install errors
sudo apt-get -y update;

# Install Node 8.x
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs;

echo "Node is installed";

echo "Installing Git";
#install git
sudo apt-get install -y git;

echo "Git is installed";

# install worker git code
git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;
npm install;

# get metadata that was passed through
workkey=`curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/key"`;
workserverIP=`curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ip"`;

echo "$workkey is key and $workserverIP is ip.";

# run client
npm run client $workkey $workserverIP:8080

# turn off the worker vm
sudo poweroff
