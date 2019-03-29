FROM ubuntu AS stage1
MAINTAINER paddyroddy.github.io

# The environment variables
ENV HOME /home
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let
ENV S2SLEPLET $HOME/s2sleplet

# install git
RUN apt-get update && apt-get install -y \
    git \
    git-lfs
RUN git lfs install

# private repos
ARG SSH_PRIVATE
RUN mkdir /root/.ssh/
RUN echo "$SSH_PRIVATE" > /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa
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

# -----------------------------------------------------------
# multistage
FROM ubuntu AS stage2

# The environment variables
ENV HOME /home

# install wget
RUN apt-get update && apt-get install -y \
    wget

# CFITSIO
WORKDIR $HOME
RUN wget \ 
   http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz \
   && tar xzf cfitsio_latest.tar.gz && rm cfitsio_latest.tar.gz

#FFTW
WORKDIR $HOME
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz && tar xzf fftw*.tar.gz \
	&& rm fftw*.tar.gz && mv fftw* $(echo fftw* | awk -F'[-]' '{print $1}')

# HEALPIX
WORKDIR $HOME
RUN wget \
   https://sourceforge.net/projects/healpix/files/Healpix_3.50/Healpix_3.50_2018Dec10.tar.gz \
   && tar xzf Healpix*.tar.gz && rm Healpix*.tar.gz \
   && mv Healpix* $(echo Healpix* | awk -F'[_]' '{print $1}')

# -----------------------------------------------------------
# multistage
FROM ubuntu AS stage3

# copy from previous builds
COPY --from=stage1 /home/ssht /home/ssht
COPY --from=stage1 /home/so3 /home/so3
COPY --from=stage1 /home/s2let /home/s2let
COPY --from=stage1 /home/s2sleplet /home/s2sleplet
COPY --from=stage2 /home/cfitsio /home/cfitsio
COPY --from=stage2 /home/fftw /home/fftw
COPY --from=stage2 /home/Healpix /home/Healpix

# The environment variables
ENV HOME /home
ENV HEALPIX $HOME/Healpix
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let
ENV S2SLEPLET $HOME/s2sleplet

# install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    gcc \
    gfortran \
    make

# CFITSIO
WORKDIR $HOME/cfitsio
RUN ./configure --prefix=/usr && make && make install
WORKDIR $HOME
RUN rm -r $HOME/cfitsio

# FFTW
WORKDIR $HOME/fftw
RUN ./configure --prefix=/usr --enable-shared --with-pic && make \
    && make install
WORKDIR $HOME
RUN rm -r $HOME/fftw

# HEALPIX
WORKDIR $HEALPIX
RUN echo \
    "3\ngfortran\n\nY\n\n\ngcc\n\n\n\n\nN\n1\nY\nN\nN\n0\n" | ./configure \
    && make

# SSHT
RUN mkdir $SSHT/build
WORKDIR $SSHT/build
RUN cmake $SSHT -Dtests=OFF && make clean all
WORKDIR $SSHT

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

# -----------------------------------------------------------
# final multibuild
FROM ubuntu

# copy from previous builds
COPY --from=stage3 /usr /usr
COPY --from=stage3 /home/ssht /home/ssht
COPY --from=stage3 /home/so3 /home/so3
COPY --from=stage3 /home/s2let /home/s2let
COPY --from=stage3 /home/s2sleplet /home/s2sleplet
COPY --from=stage3 /home/Healpix /home/Healpix

# The environment variables
ENV HOME /home
ENV CFITSIO /usr
ENV FFTW /usr/local
ENV HEALPIX $HOME/Healpix
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let
ENV S2SLEPLET $HOME/s2sleplet

# install python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

# python packages
RUN pip3 install numpy Cython==0.27.3 matplotlib scipy healpy plotly pyyaml

# ssht
WORKDIR $SSHT
RUN python3 setup.py build_ext --inplace

# s2let
WORKDIR $S2LET
RUN python3 setup.py build_ext --inplace

# s2slplet
WORKDIR $S2SLEPLET
