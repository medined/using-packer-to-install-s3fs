#!/bin/bash

PUBLIC_IP=$(terraform output public_ip)

# Get the controller's SSH fingerprint.
ssh-keygen -R $PUBLIC_IP > /dev/null 2>&1
ssh-keyscan -H $PUBLIC_IP >> ~/.ssh/known_hosts 2>/dev/null

ssh  -i ./tf-packer centos@$PUBLIC_IP
