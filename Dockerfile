# 99a769f533440a3abe86c6a1796cb08980f4cab3d9bdcce4b792f58866e827de
# Dockerfile generated by Maru 0.1.1

# Staged build using builder container
FROM scientificlinux/sl:7 as builder
ARG GIT_TAG=dev

RUN yum install -y git curl openssh gcc
RUN yum install -y unzip
RUN yum install -y make
RUN yum install -y gcc-c++

# for building and running R
RUN yum install -y gcc-gfortran
RUN yum install -y zlib-devel bzip2-devel xz-devel
RUN yum install -y pcre pcre-devel
RUN yum install -y libcurl-devel
RUN yum install -y ghostscript

# for building samtools
RUN yum install -y ncurses-devel

# for installing Perl packages
RUN yum install -y perl-App-cpanminus
RUN yum install -y perl-Switch

# Checkout and build the code
WORKDIR /app
RUN git clone --branch $GIT_TAG --depth 1 https://github.com/YourePrettyGood/msg .

WORKDIR /app/dependencies
RUN curl -sO https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
RUN curl -sO https://cran.r-project.org/src/base/R-3/R-3.4.0.tar.gz
RUN cat *.{tar.gz,tgz} | tar zxvf - -i \
    && cat *.tar.bz2 | tar jxvf - -i \
    && unzip *.zip

# core executables
WORKDIR /app/dependencies/Python-2.7.18
RUN ./configure && make && make install

WORKDIR /app/dependencies/R-3.4.0
RUN ./configure --with-readline=no --with-x=no F77=gfortran \
    && make && make install

WORKDIR /app/dependencies/bwa-0.5.7
RUN make && cp bwa /usr/local/bin

# R packages
RUN R -e "install.packages('HiddenMarkov',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('R.methodsS3',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('R.oo',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Python packages
WORKDIR /app/dependencies/Pyrex-0.9.9
RUN python setup.py install

WORKDIR /app/dependencies/numpy-1.5.1
RUN python setup.py build --fcompiler=gnu95 && python setup.py install

WORKDIR /app/dependencies/biopython-1.53
RUN python setup.py install

WORKDIR /app/dependencies/pysam-0.1.2
RUN python setup.py install

# Perl module
RUN cpanm IO::Uncompress::Gunzip

# msg, samtools, and stampy share the same makefile; note that
# samtools and stampy build in /app, not in /app/dependencies!
WORKDIR /app
RUN make
RUN make samtools && cp /app/samtools-0.1.9/samtools /usr/local/bin
RUN make stampy \
    && cp /app/stampy-1.0.32/stampy.py /usr/local/bin \
    && cp /app/stampy-1.0.32/maptools.so /usr/local/lib/python2.7/site-packages \
    && cp -R /app/stampy-1.0.32/Stampy /usr/local/lib/python2.7/site-packages/Stampy \
    && cp -R /app/stampy-1.0.32/plugins /usr/local/lib/python2.7/site-packages/plugins \
    && cp -R /app/stampy-1.0.32/ext /usr/local/lib/python2.7/site-packages/ext



# test script, will be removed
COPY testscript.sh /app



# in final form, we'll remove these; for now, makes testing easier with them present
# RUN rm -rf /app/dependencies




# Create final image
FROM scientificlinux/sl:7

COPY --from=builder / /



# Add Tini
# ENV TINI_VERSION v0.19.0
# ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
# RUN chmod +x /tini
# ENTRYPOINT ["/tini", "--"]

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]




# for testing; this runs the test_dependencies.sh script
# ENTRYPOINT ["/bin/sh", "/app/testscript.sh"]
