#!/usr/bin/env bash

## Copyright (C) 2019-2021 The VSL Team
## Licensed under MIT
##
##     @script.name [OPTION] ARGUMENTS...
##
## Options:
##     -h, --help                            Prints usage and example
##         --venv=PATH                       Virtual Env path
##

ROOT=$(dirname "$0")

source "${ROOT}/../bin/util/opts/opts.sh" || exit
source "${ROOT}/python.sh"

if [ -d "${venv}" ]; then
    exit 0
fi

"${python_bin}" -m venv "${venv}"
source "${venv}/bin/activate"
"${python_bin}" -m pip install cython
"${python_bin}" -m pip install plotly numpy
deactivate
