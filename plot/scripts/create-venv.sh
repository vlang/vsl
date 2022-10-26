#!/usr/bin/env bash

ROOT=$(dirname "$0")

usage() {
    echo "Usage: ${0} <venv_path>"
    exit 1
}

VENV="${1}"

if [ -z "${VENV}" ]; then
    usage
fi

source "${ROOT}/python.sh" || exit

if [ -d "${VENV}" ]; then
    exit 0
fi

"${python_bin}" -m venv "${VENV}"
source "${VENV}/bin/activate"
"${python_bin}" -m pip install cython
"${python_bin}" -m pip install plotly numpy
deactivate
