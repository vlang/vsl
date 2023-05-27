#!/usr/bin/env bash

# Syntax: ./vsl-clone-and-build.sh [DEV_IMG] [VSL_VERSION]

DEV_IMG=${1:-"false"}
VSL_VERSION=${2:-"latest"}

if [ "${DEV_IMG}" = "true" ]; then
  exit 0
fi

BRANCH="v${VSL_VERSION}"
if [ "${VSL_VERSION}" = "latest" ]; then
  BRANCH="main"
fi

git clone -b $BRANCH --single-branch --depth 1 https://github.com/vlang/vsl.git /opt/vlang/vlib/vsl
