FROM alpine AS stage1
LABEL maintainer="paddyroddy.github.io"

# environment variables
ENV HOME /home
ENV SSHT $HOME/ssht
ENV SO3 $HOME/so3
ENV S2LET $HOME/s2let

# install git
RUN apk --no-cache add -t .build-dep \
    git \
    openssh-client \
    wget

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

# CFITSIO
WORKDIR $HOME
RUN wget \ 
    http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz \
    && tar xzf cfitsio_latest.tar.gz && rm cfitsio_latest.tar.gz \
    && mv cfitsio* $(echo cfitsio* | awk -F'[-]' '{print $1}')

# FFTW
WORKDIR $HOME
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz && tar xzf fftw*.tar.gz \
    && rm fftw*.tar.gz && mv fftw* $(echo fftw* | awk -F'[-]' '{print $1}')

# HEALPIX
WORKDIR $HOME
RUN wget \
    https://sourceforge.net/projects/healpix/files/Healpix_3.60/Healpix_3.60_2019Dec18.tar.gz \
    && tar xzf Healpix*.tar.gz && rm Healpix*.tar.gz \
    && mv Healpix* $(echo Healpix* | awk -F'[_]' '{print $1}')

# clean
RUN apk del .build-dep

# -----------------------------------------------------------
# final stage
FROM python

# copy from previous builds
COPY --from=stage1 /home/ssht /home/project/src/ssht
COPY --from=stage1 /home/so3 /home/project/src/so3
COPY --from=stage1 /home/s2let /home/project/src/s2let
COPY --from=stage1 /home/cfitsio /home/cfitsio
COPY --from=stage1 /home/fftw /home/fftw
COPY --from=stage1 /home/Healpix /home/Healpix

# The environment variables
ENV HOME /home
ENV CFITSIO /usr
ENV FFTW /usr/local
ENV HEALPIX $HOME/Healpix
ENV SSHT $HOME/project/src/ssht
ENV SO3 $HOME/project/src/so3
ENV S2LET $HOME/project/src/s2let

# install dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    gcc \
    gfortran \
    libmpc-dev \
    libmpfr-dev \
    make \
    && rm -rf /var/lib/apt/lists/*

# CFITSIO
WORKDIR $HOME/cfitsio
RUN bash configure --prefix=/usr && make && make install
WORKDIR $HOME
RUN rm -r $HOME/cfitsio

# FFTW
WORKDIR $HOME/fftw
RUN bash configure --prefix=/usr --enable-shared --with-pic && make \
    && make install
WORKDIR $HOME
RUN rm -r $HOME/fftw

# HEALPIX
WORKDIR $HEALPIX
RUN /bin/echo -e \
    "3\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ny\n\n" | bash configure \
    && make

# SSHT
RUN mkdir $SSHT/build
WORKDIR $SSHT/build
RUN cmake .. -Dtests=OFF && make clean all

# SO3
RUN mkdir $SO3/build
WORKDIR $SO3/build
RUN cmake .. -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/src/c/libssht.a -Dtests=OFF \
    && make clean all

# S2LET
RUN mkdir $S2LET/build
WORKDIR $S2LET/build
RUN cmake .. -DSsht_INCLUDE_DIR=$SSHT/src/c/ \
    -DSsht_LIBRARY=$SSHT/build/src/c/libssht.a -DSo3_INCLUDE_DIR=$SO3/include/ \
    -DSo3_LIBRARY=$SO3/build/libso3.a -Dtests=OFF && make clean all

# ssht
WORKDIR $SSHT
RUN pip install .

# s2let
WORKDIR $S2LET
RUN python setup.py build_ext --inplace

# home
WORKDIR $HOME
