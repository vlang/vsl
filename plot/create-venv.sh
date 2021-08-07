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

if ! type -p python &>/dev/null; then
    echo "Install Python 3 and link it to python binary."
    exit 1
fi

pyver=$(python -c "import platform; print(str(platform.python_version()).split('.')[0])")

if [[ "${pyver}" != "3" ]]; then
    echo "The detected Python version is < 3.0.0,
please update your Python version to 3+. If you already have
    Python 3+ under 'python3', please link 'python3' to python binary."
    exit 1
fi

if [ -d "${venv}" ]; then
    exit 0
fi

python -m venv "${venv}"
source "${venv}/bin/activate"
pip install plotly numpy
deactivate
