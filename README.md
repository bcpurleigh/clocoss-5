# gcloud Master Worker VM Tool: clocoss-5

A tool used to create and implement the [clocoss-master-worker](https://github.com/portsoc/clocoss-master-worker/) script.

## Installation:
1. Clone the repo to a [Google Cloud SDK](https://cloud.google.com/sdk/docs/) enabled cli with https,http-server tags and full access to the Google Cloud API enabled.
2. Enter the clocoss-5 directory (or wherever you installed to) then run:
```
bash startup.sh <<number of vms to create>>
```

For example:
```
bash startup.sh 4
```
3. Sit back and wait for all 200 puzzles to complete.
