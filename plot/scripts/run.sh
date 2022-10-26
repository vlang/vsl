#!/usr/bin/env bash

ROOT=$(dirname "$0")

usage() {
    echo "Usage: ${0} <venv_path> <data_path> <label_path>"
    exit 1
}

VENV="${1}"
DATA="${2}"
LAYOUT="${3}"

if [ -z "${VENV}" ] || [ -z "${DATA}" ] || [ -z "${LAYOUT}" ]; then
    usage
fi

source "${ROOT}/python.sh" || exit

"${ROOT}"/create-venv.sh "${VENV}" || exit

source "${VENV}/bin/activate"
"${python_bin}" "${ROOT}/plotter.py" --data "${DATA}" --layout "${LAYOUT}"
deactivate
