#!/bin/bash

gcloud compute instances detach-disk my-vm-instance \
  --disk my-persistent-disk \
  --zone us-central1-a

gcloud compute instances delete my-vm-instance \
  --zone us-central1-a \
  --quiet

gcloud compute disks delete my-persistent-disk \
  --zone us-central1-a \
  --quiet
