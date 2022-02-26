#!/usr/bin/env bash

## Copyright (C) 2019-2021 The VSL Team
## Licensed under MIT
##
##     @script.name [OPTION] ARGUMENTS...
##
## Options:
##     -h, --help                            Prints usage and example
##         --venv=PATH                       Virtual Env path
##         --data=PATH                       Path to the JSON file that contains the data
##         --layout=PATH                     Path to the JSON file that contains the layout
##

ROOT=$(dirname "$0")

source "${ROOT}/../bin/util/opts/opts.sh" || exit
source "${ROOT}/python.sh"

bash "${ROOT}"/create-venv.sh --venv="${venv}"

source "${venv}/bin/activate"
"${python_bin}" "${ROOT}/plotter.py" --data "${data}" --layout "${layout}"
deactivate
