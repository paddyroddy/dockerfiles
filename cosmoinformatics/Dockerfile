FROM ubuntu AS intermediate
LABEL maintainer="patrick.roddy.17@ucl.ac.uk"

# The environment variables
ENV HOME /home
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let
ENV S2SLEPLET $HOME/s2sleplet

# install git
RUN apt-get update -y && apt-get install -y git git-lfs && git lfs install

# private repos
ARG SSH_PRIVATE
RUN mkdir /root/.ssh/
RUN echo "$SSH_PRIVATE" > /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# ssht
RUN git clone git@github.com:astro-informatics/src_ssht.git $SSHT
WORKDIR $SSHT
RUN git checkout paddy

# so3
RUN git clone git@github.com:astro-informatics/src_so3.git $SO3
WORKDIR $SO3
RUN git checkout paddy

# s2let
RUN git clone git@github.com:astro-informatics/src_s2let.git $S2LET
WORKDIR $S2LET
RUN git checkout paddy

# s2let
RUN git clone git@github.com:astro-informatics/src_s2sleplet.git $S2SLEPLET

# multibuild
FROM ubuntu
COPY --from=intermediate /home/ssht /home/ssht
COPY --from=intermediate /home/so3 /home/so3
COPY --from=intermediate /home/s2let /home/s2let
COPY --from=intermediate /home/s2sleplet /home/s2sleplet

# Basic compilers and tools dependencies
RUN apt-get update -y && apt-get install -y \
    gcc gfortran wget make cmake python3 python3-pip \
    && apt-get clean all

# The environment variables
ENV HOME /home
ENV CFITSIO /usr
ENV FFTW /usr/local
ENV HEALPIX $HOME/Healpix_3.50
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let
ENV S2SLEPLET $HOME/s2sleplet

# CFITSIO
WORKDIR $HOME
RUN wget \ 
   http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz \
   && tar xzf cfitsio_latest.tar.gz && rm cfitsio_latest.tar.gz
WORKDIR $HOME/cfitsio
RUN ./configure --prefix=/usr && make && make install

#FFTW
WORKDIR $HOME
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz && tar xzf fftw-3.3.8.tar.gz \
   && rm fftw-3.3.8.tar.gz && mv fftw-3.3.8 fftw
WORKDIR $HOME/fftw
RUN ./configure --prefix=/usr --enable-shared --with-pic && make \
   && make install

# HEALPIX
WORKDIR $HOME
RUN wget \
   https://sourceforge.net/projects/healpix/files/Healpix_3.50/Healpix_3.50_2018Dec10.tar.gz \
   && tar xzf Healpix_3.50_2018Dec10.tar.gz && rm Healpix_3.50_2018Dec10.tar.gz
WORKDIR $HEALPIX
RUN echo \
   "3\ngfortran\n\nY\n\n\ngcc\n\n\n\n\nN\n1\nY\nN\nN\n0\n" | ./configure \
   && make

# python
RUN pip3 install numpy Cython==0.27.3 matplotlib scipy healpy

# SSHT
RUN mkdir $SSHT/build
WORKDIR $SSHT/build
RUN cmake $SSHT -Dtests=OFF && make clean all
WORKDIR $SSHT
RUN python3 setup.py build_ext --inplace

# SO3
RUN mkdir $SO3/build
WORKDIR $SO3/build
RUN cmake $SO3 -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/libssht.a -Dtests=OFF \
    && make clean all

# S2LET
RUN mkdir $S2LET/build
WORKDIR $S2LET/build
RUN cmake $S2LET -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/libssht.a -DSo3_INCLUDE_DIR=$SO3/src/c/ \
    -DSo3_LIBRARY=$SO3/build/libso3.a -Dtests=OFF && make clean all
WORKDIR $S2LET
RUN python3 setup.py build_ext --inplace

# s2slplet
WORKDIR $S2SLEPLET
