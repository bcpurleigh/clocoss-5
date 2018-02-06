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


# Create the VMs
echo "Beginning to create Cloud Worker VMs.";
for i in `seq 1 $vms`
do
gcloud compute instances create  \
--machine-type n1-standard-1  \
--tags http-server,https-server  \
--metadata key=$key,ip=$externalIP,num=$i  \
--metadata-from-file  \
          startup-script=../startup-script.sh  \
ben-worker-$i \
--preemptible &
done

# Run the server
echo "Starting master server. The workers will start working soon.";
npm run server $key;

# Tasks completed
echo "All puzzles completed. Main process finished.";

# Delete the worker VMs
echo "Deleting the workers VMs and their disks if they are not already destroyed. This may take a short time.";
gcloud -q compute instances delete `seq -f 'ben-worker-%g' 1 $vms` &

#ensure everything else has finished first
wait "$!"

# We're done here
echo "All worker VMs deleted. All done. Thank you!";
