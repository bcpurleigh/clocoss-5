#!/bin/bash

# startup.sh numOfVms
echo "Script Started!";

echo "Updating apt-get and installing prereqs. (Git, Node)"
# Updating apt-get to remove Git install errors
sudo apt-get -y update;
sudo apt-get install -y git;
# Install Node 8.x
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install -y nodejs;

echo "PreReqs installed.";

echo "Cloning clocoss-master-worker from Git and installing."
# Install clocoss-master-worker code from Git
git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;
npm install;
echo "clocoss-master-worker installed and directory changed.";

#set secret keys
key=`openssl rand -base64 32`;

# get number of number of VMs
vms=$1;
echo "The number of worker VMs to create is $vms";

# set google cloud server location
echo "Setting GCloud Compute Zone";
gcloud config set compute/zone europe-west1-d;

# get external ip
externalIP=`curl -s -H "Metadata-Flavor: Google"  \
   "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"`;
echo "The external IP is $externalIP";

# Run the server
echo "Starting master server";
npm run server $key &

# Create the VMs
echo "Creating Cloud Worker VMs. This will take a while.";
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
# Tasks completed
echo "All puzzles completed.";

# Delete the worker VMs
echo "Deleting the workers VMs and their disks";
gcloud -q compute instances delete `seq -f 'ben-worker-%g' 1 $vms`;

# Report back who contributed
echo "Who actually did some work?";
gcloud beta logging read "logName=projects/clocoss-2017/logs/clocoss-m
aster-worker AND severity=info" --limit=$vms

# We're done here
echo "All done. Thank you!";
