ARG VLANG_TAG=buster-dev

FROM thevlang/vlang:${VLANG_TAG} AS builder
# VLANG_TAG is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG VLANG_TAG

# options
ARG DEV_IMG="false"

# disable tzdata questions
ENV DEBIAN_FRONTEND=noninteractive

# use bash
SHELL ["/bin/bash", "-c"]

# install apt-utils
RUN apt-get update -y \
  && apt-get install -y apt-utils 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 ) \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# essential tools
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    netbase \
    curl \
    git \
    make \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# required compilers and libraries for vsl
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python3.8 \
    python3-pip \
    python3.8-dev \
    gcc \
    gfortran \
    libxi-dev \
    libxcursor-dev \
    mesa-common-dev \
    liblapacke-dev \
    libopenblas-dev \
    libgc-dev \
    libgl1-mesa-dev \
    libopenmpi-dev \
    libhdf5-dev \
    hdf5-tools \
    opencl-headers \
    libmetis-dev \
    libsuitesparse-dev \
    libmumps-dev \
    libfftw3-dev \
    libfftw3-mpi-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV EDITOR code

# build vsl
ARG VSL_VERSION="latest"
COPY docker/vsl-clone-and-build.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/vsl-clone-and-build.sh "${DEV_IMG}" "${VSL_VERSION}"
