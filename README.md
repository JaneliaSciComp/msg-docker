# msg-docker


**Documentation in progress!**


This repo containerizes the MSG pipeline used by the Stern lab. It relies on a lot of very old dependencies, so we've frozen the pipeline in approximately its late-2020 state to ensure it can be run into the future in whatever environment is available.

## Container contents

* msg repo: https://github.com/JaneliaSciComp/msg
    - dev branch
    - it's cloned into `/app`
* Scientific Linux 7 base image
* Python 2.7, R 3.4.0
* many dependencies are stored in the msg repo and built from there
* the rest we get from various repositories
    - yum install
    - R packages from cran.rstudio.com
    - Perl packages via CPAN
* to support the Janelia cluster, Python 3 is also installed
    - "python" is Python 2.7, however, as needed by MSG


## Building

**Meta**
* Docker container 
* we use maru to build the container (https://github.com/JaneliaSciComp/maru), but you can build with Docker as well

**Build**
* install Docker (and optionally maru)
* clone this repo
* cd into repo
* `maru build` or `docker build something something`
    - this will take tens of minutes (an hour or more?) the first time it's run
    - later invocations will be shorter, depending on how many cached layers of the Docker image can be reused

**Registry**

We are storing the container in the internal Janelia registry at `sternlab/msg`. To tag and upload:

* docker tag blah blah blah
* docker push tag registry
* note this address and tag for later use!


## Running msg

`/app/msgCluster.pl` is the default entry point of the container.


**Single computer**

* cd into data directory
* be sure `cluster=0` in `msg.cfg`
* `maru run` or `docker run something something`


**Cluster**

These instructions are for the Janelia cluster using Singularity to run the Docker container.

* cd into data dir
* adjust `msg.cfg`
    - add bsub submit line
    - set cluster=1
    - add container line
    - do not set any paths or file locations
* submit with this: blah blah blah

**Shell access**

If you need interactive access to the container:

* `maru shell` or `docker -it exec containername /bin/bash`




