#!/bin/sh

# test script for helping me debug the container

cd /app

# my spot checks
python --version

# random stuff
which gfortran
which f77

# the thing we want to run clean:
./test_dependencies.sh