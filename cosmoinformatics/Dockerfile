FROM ubuntu:18.10
LABEL maintainer="patrick.roddy.17@ucl.ac.uk"
# docker build -t cosmoinformatics .
# docker run -it --rm cosmoinformatics

ENV DEBIAN_FRONTEND noninteractive

# The environment variables
ENV HOME /home
ENV CFITSIO /usr
ENV FFTW /usr
ENV HEALPIX $HOME/Healpix_3.40
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let

# Basic compilers and tools dependencies
RUN apt-get update -y && apt-get install -y \
    gcc g++ gfortran wget make git cmake build-essential vim

# Simple install of python
RUN apt-get install -y python3 python3-pip python3-dev \
    && apt-get clean all

# CFITSIO
WORKDIR $HOME
RUN wget \ 
    http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz \
    && tar xzf cfitsio_latest.tar.gz && rm cfitsio_latest.tar.gz
WORKDIR $HOME/cfitsio
RUN ./configure --prefix=/usr && make && make install
WORKDIR $HOME

#FFTW
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz && tar xzf fftw-3.3.8.tar.gz \
    && rm fftw-3.3.8.tar.gz && mv fftw-3.3.8 fftw
WORKDIR $HOME/fftw
RUN ./configure --prefix=/usr --enable-shared --with-pic && make \
    && make install
WORKDIR $HOME

# HEALPIX
RUN wget \
    https://downloads.sourceforge.net/project/healpix/Healpix_3.40/Healpix_3.40_2018Jun22.tar.gz \
    && tar xzf Healpix_3.40_2018Jun22.tar.gz && rm Healpix_3.40_2018Jun22.tar.gz
WORKDIR $HEALPIX
RUN echo \
    "3\ngfortran\n\nY\n\n\ngcc\n\n\n\n\nN\n1\nY\nN\nN\n0\n" | ./configure \
    && make
# 3 gfortran ↵ ↵ ↵ ↵ ↵ ↵ ↵ ↵ N ↵ Y N
WORKDIR $HOME

# python
RUN pip3 install numpy Cython==0.27.3 matplotlib scipy healpy

# private repos
RUN mkdir /root/.ssh/
COPY id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# SSHT
RUN git clone git@github.com:astro-informatics/src_ssht.git $SSHT \
    && mkdir $SSHT/build
WORKDIR $SSHT/build
RUN cmake $SSHT -Dtests=OFF && make clean all
WORKDIR $SSHT
RUN python3 setup.py build_ext --inplace
WORKDIR $HOME

# SO3
RUN git clone git@github.com:astro-informatics/src_so3.git $SO3 \
    && mkdir $SO3/build
WORKDIR $SO3/build
RUN cmake $SO3 -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/libssht.a -Dtests=OFF \
    && make clean all
WORKDIR $HOME

# S2LET
RUN git clone git@github.com:astro-informatics/src_s2let.git $S2LET \
    && mkdir $S2LET/build
WORKDIR $S2LET/build
RUN cmake $S2LET -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/libssht.a -DSo3_INCLUDE_DIR=$SO3/src/c/ \
    -DSo3_LIBRARY=$SO3/build/libso3.a -Dtests=OFF && make clean all
WORKDIR $S2LET
RUN python3 setup.py build_ext --inplace
WORKDIR $HOME

# cleanup
RUN rm -r /tmp
