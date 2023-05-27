ARG VLANG_TAG=buster-dev

FROM --platform=$BUILDPLATFORM thevlang/vlang:${VLANG_TAG} AS vsl
# VLANG_TAG is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG VLANG_TAG

# options
ARG DEV_IMG="false"

# disable tzdata questions
ENV DEBIAN_FRONTEND=noninteractive

# use bash
SHELL ["/bin/bash", "-c"]

RUN <<EOF
apt-get update -y
apt-get install -y --no-install-recommends \
  # install apt-utils to avoid warning messages
  apt-utils 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 ) \
  # essential tools for development
  ca-certificates \
  netbase \
  curl \
  git \
  make \
  # required compilers and libraries for vsl
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
EOF

# build vsl
ARG VSL_VERSION="latest"
COPY docker/vsl-clone-and-build.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/vsl-clone-and-build.sh "${DEV_IMG}" "${VSL_VERSION}"

FROM vsl AS vsl-dev

ENV EDITOR code

##################################################################################################
#                                                                                                #
#   The code below is copied from:                                                               #
#      https://github.com/microsoft/vscode-remote-try-go/blob/master/.devcontainer/Dockerfile    #
#   And modifies to use v lang instead                                                           #
#                                                                                                #
##################################################################################################

# Options for setup script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY docker/common-debian.sh /tmp/library-scripts/
RUN apt-get update \
  && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# install Docker tools (cli, buildx, compose)
COPY --from=gloursdocker/docker / /
