#!/bin/bash

if [ ! -f source.me ]; then
    echo "Missing file: source.me"
    exit
fi
source source.me

if [ -z $AWS_PROFILE ]; then
    echo "Missing environment variable: AWS_PROFILE"
    exit
fi

grep -A 1 $AWS_PROFILE ~/.aws/credentials >/dev/null
if [ $? != 0 ]; then
    echo "AWS Profile not found in ~/.aws/credentials file."
    exit
fi

if [ -z $PACKER_BUILDER_INSTANCE_PROFILE ]; then
    echo "Missing environment variable: PACKER_BUILDER_INSTANCE_PROFILE"
    exit
fi

if [ ! -f s3fs-bucket.txt ]; then
    echo "Missing configuration file: s3fs-bucket.txt"
    exit
fi

# I don't know which order the keys are in. But we do know the key lengths.

KEY1=$(grep -A 1 $AWS_PROFILE ~/.aws/credentials | tail -n 1 | tr -d ' ' | cut -d'=' -f2)
KEY2=$(grep -A 2 $AWS_PROFILE ~/.aws/credentials | tail -n 1 | tr -d ' ' | cut -d'=' -f2)

if [ "${#KEY1}" == "20" ]; then
    export AWS_ACCESS_KEY_ID=$KEY1
else
    if [ "${#KEY1}" == "40" ]; then
        export AWS_SECRET_ACCESS_KEY=$KEY1
    fi
fi

if [ "${#KEY2}" == "20" ]; then
    export AWS_ACCESS_KEY_ID=$KEY2
else
    if [ "${#KEY2}" == "40" ]; then
        export AWS_SECRET_ACCESS_KEY=$KEY2
    fi
fi

#
# Make sure the S3FS bucket exists.
#
echo "If the bucket exists, you will see an Access Denied message."
aws s3 mb s3://$(cat s3fs-bucket.txt)

PACKER_FILE="centos.json"

packer validate $PACKER_FILE
if [ $? != 0 ]; then
    echo "Fix errors in $PACKER_FILE."
    exit
fi

packer build $PACKER_FILE | tee /tmp/packer.log

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
