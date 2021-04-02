# msg-docker

This repo containerizes the MSG "Multiplexed Shotgun Genotyping" pipeline found [here](https://github.com/JaneliaSciComp/msg). The pipeline relies on a lot of very old dependencies, so we've frozen it in approximately its late-2020 state to ensure it can be run into the future in whatever environment is available.

This documentation is not meant to replace [Docker documentation](https://docs.docker.com). However, if you've installed Docker and gone through even the first pages of the both the Docker and Docker Hub QuickStarts, you will probably be able to follow the instructions for running the MSG container from Docker Hub. If you want to build the container yourself, you'll need a bit more Docker experience. 

## Container contents

* it's a Docker container
* MSG repo: https://github.com/JaneliaSciComp/msg
    - dev branch
    - inside the container, the repo is cloned into `/app`
* Scientific Linux 7 base image
* Python 2.7, R 3.4.0
    - to support the Janelia cluster, Python 3 is also installed
    - the versionless "python" command, however, resolves to Python 2.7, as needed by MSG
* many dependencies are stored in the MSG repo and built from source
* the rest we get from various online repositories
    - yum install
    - R packages from cran.rstudio.com
    - Perl packages from CPAN

## Building

We use [maru](https://github.com/JaneliaSciComp/maru) to build the container, but you can build with Docker as well.

* install Docker (and optionally maru)
* clone this repo
* cd into repo
* `maru build` or `docker build -t <tag> .`
    - this will take ten minutes or more the first time it's run
        + later invocations will be shorter, depending on how many cached layers of the Docker image can be reused
    - `<tag>` should be `msg:x.y.z` (with appropriate version number x.y.z)
    - if you build with maru, the tag will be set as specified in `maru.yaml`

## Running

Full documentation on running MSG is found in [its repo](https://github.com/JaneliaSciComp/msg). This is a summary of the steps needed to run it within a Docker container. You should prepare your data and configuration files as you would for running without using a container.

The Docker image is availabe on Docker Hub at `docker://janeliascicomp/msg:x.y.z`, where x.y.z is the version number. `msgCluster.pl` is run by default when you run the container. So to run `msgCluster.pl` as you would interactively, you will `cd` into your data directory and issue a command like this (using a valid version number):

`docker run --rm docker://janeliascicomp/msg:x.y.z`

If you have a cluster that is capable of running containers, you should adjust your `msg.cfg` as normal for cluster use. There is an additional option `default_container_options` where you will specify the commands your cluster requires to retrieve and run the container from Docker Hub.

See below for an example of how we run MSG on our LSF cluster using Singularity.

**Note:** Since `/app/msgCluster.pl` is the default entry point of the container, if you need to run (eg) `msgUpdateParentals.pl`, you will need to open a shell in the container and do it there.


## Running on the Janelia cluster

These instructions are for the Janelia cluster using Singularity to run the Docker container.

* adjust `msg.cfg`
    - adjust the submit command line:
        `submit_cmd = source /misc/lsf/conf/profile.lsf; bsub -J $jobname -o $logdir/$jobname.stdout -e $logdir/$jobname.stderr -o $logdir/$jobname.stdout -e $logdir/$jobname.stderr`
    - set `cluster=1`
    - add a line for the container options; make sure the address and version number (x.y.z) are correct and current:
        `default_container_options = singularity exec docker://janeliascicomp/msg:x.y.z`
    - _do not_ explicitly specify any file paths for anything in the container
* log on to a cluster submit host
* cd into your data dir
* submit using this line:
    `bsub -n 1 singularity run -B /misc/lsf docker://janeliascicomp/msg:x.y.z`

We are also storing the container in the internal Janelia registry as `sternlab/msg:x.y.z`. If you prefer, you can retrieve the container from there instead of Docker Hub.





