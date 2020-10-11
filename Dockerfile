ARG OPENBLAS_VERSION=0.3.1

FROM slothai/openblas:${OPENBLAS_VERSION} as openblas
FROM thevlang/vlang

# OPENBLAS_VERSION is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)

ARG OPENBLAS_VERSION

COPY --from=openblas /opt/OpenBLAS/ /opt/OpenBLAS/
ARG USER=test

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        clang \
        make \
        git \
        net-tools \
        sudo \
        neovim \
        apt-utils \
        locales \
        git \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

ENV EDITOR nvim

RUN useradd -m ${USER} \
    && passwd -d ${USER} \
    && sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers \
    && echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && usermod -a -G sudo ${USER} \
    && rm -rf /home/${USER}/.bashrc

# Set correct locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN locale-gen en_US.UTF-8
ENV LC_CTYPE 'en_US.UTF-8'
ENV LANG C.UTF-8

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
