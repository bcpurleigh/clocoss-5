#!/bin/bash

# startup.sh numOfVms
echo "Script Started!";

echo "Updating apt-get as sudo to stop errors."
# Updating apt-get to remove Git install errors
sudo apt-get -y update;

echo "apt-get installed.";

echo "Installing Git";
#install git
sudo apt-get install -y git;

echo "Git is installed";

echo "Installing node";

# Install Node 8.x
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install -y nodejs;

echo "Node is installed";

node=`node -v`;

echo "Node Version: $node" ;

echo "Cloning clocoss-master-worker from Git and installing."

# Install clocoss-master-worker code from Git
git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;
npm install;

echo "clocoss-master-worker installed and directory changed.";

echo "Generating random key";

#set secret keys
key=`openssl rand -base64 32`;

echo "The secret key is $key, don't tell anyone!";

# get number of number of VMs
echo "Counting VMs";
vms=$1;
echo "The number of worker VMs to create is $vms";

# set google cloud server location
echo "Setting GCloud Compute Zone";
gcloud config set compute/zone europe-west1-d;

echo "Getting the Master Server IP";
# get external ip
externalIP=`curl -s -H "Metadata-Flavor: Google"  \
   "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"`;
echo "External IP is $externalIP";



echo "Starting master server";
npm run server $key &

echo "Creating Cloud Worker VMs";

# create vms
for i in `seq 1 $vms`
do
gcloud compute instances create  \
--machine-type n1-standard-1  \
--tags http-server,https-server  \
--metadata key=$key,ip=$externalIP,num=$i  \
--metadata-from-file  \
          startup-script=../startup-script.sh  \
ben-worker-$i \
--preemptible;
done

echo "VMs created, sit tight.";



# Tasks completed
echo "All puzzles completed.";

# Delete the worker VMs
echo "Deleting the workers VMs and their disks";

gcloud -q compute instances delete `seq -f 'ben-worker-%g' 1 $vms`;
gcloud logging read vm-logger

# We're done here
echo "All done. Thank you!";
