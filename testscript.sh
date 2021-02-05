#!/bin/sh

# test script for helping me debug the container

# my spot checks
echo $PATH

ls -al /app/dependencies/samtools-0.1.9

ls -al /usr/local/bin

# the thing we want to run clean:
cd /app
/app/test_dependencies.sh