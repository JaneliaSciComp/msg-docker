# msg-docker


**Documentation in progress!**


This repo containerizes the MSG pipeline used by the Stern lab. It relies on a lot of very old dependencies, so we've frozen the pipeline in approximately its late-2020 state to ensure it can be run into the future in whatever environment is available.

## Container contents

* msg repo: https://github.com/JaneliaSciComp/msg
    - dev branch
    - it's cloned into `/app`
* Scientific Linux 7 base image
* Python 2.7, R 3.4.0
* many dependencies are stored in the MSG repo and built from source
* the rest we get from various repositories
    - yum install
    - R packages from cran.rstudio.com
    - Perl packages via CPAN
* to support the Janelia cluster, Python 3 is also installed
    - "python", however, resolves to Python 2.7, as needed by MSG


## Building

**Meta**
* Docker container 
* we use maru to build the container (https://github.com/JaneliaSciComp/maru), but you can build with Docker as well

**Build**
* install Docker (and optionally maru)
* clone this repo
* cd into repo
* `maru build` or `docker build -t <tag> .`
    - this will take ten minutes or more the first time it's run
        + later invocations will be shorter, depending on how many cached layers of the Docker image can be reused
    - `<tag>` should be msg:x.y.z (with appropriate version number x.y.z)


**Registry**

We are storing the container in the internal Janelia registry at `sternlab/msg`. To tag (using the same version number as above) and upload:

* `docker tag msg:x.y.z registry.int.janelia.org/sternlab/msg:x.y.z`
* if you aren't logged in: `docker login registry.int.janelia.org`
* `docker push registry.int.janelia.org/sternlab/msg:x.y.z`
    - this can take several minutes

Note this address and tag for later use!


## Running MSG on the Janelia cluster

Note that `/app/msgCluster.pl` is the default entry point of the container. If you need to run (eg) `msgUpdateParentals.pl`, you will need to open a shell in the container and do it there.

These instructions are for the Janelia cluster using Singularity to run the Docker container.

* adjust `msg.cfg`
    - adjust the submit command line:
        `submit_cmd = source /misc/lsf/conf/profile.lsf; bsub -J $jobname -o $logdir/$jobname.stdout -e $logdir/$jobname.stderr -o $logdir/$jobname.stdout -e $logdir/$jobname.stderr`
    - set `cluster=1`
    - add a line for the container options; make sure the address and version number (x.y.z) are correct and current:
        `default_container_options = singularity exec docker://registry.int.janelia.org/sternlab/msg:x.y.z`
    - _do not_ set any paths or file locations within MSG
* log on to a cluster submit host
* cd into your data dir
* submit using this line, again:
    `bsub -n 1 singularity run -B /misc/lsf docker://registry.int.janelia.org/sternlab/msg:x.y.z`






