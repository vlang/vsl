#!/usr/bin/env bash

python_bin="python"

if type -p python3 &>/dev/null; then
    python_bin="python3"
fi

if ! type -p "${python_bin}" &>/dev/null; then
    echo "Install Python 3 and link it to python or python3 binary."
    exit 1
fi

pyver=$("${python_bin}" -c "import platform; print(str(platform.python_version()).split('.')[0])")

if [[ "${pyver}" != "3" ]]; then
    echo "The detected Python version is < 3.0.0,
please update your Python version to 3+. If you already have
    Python 3+ under '${python_bin}', please link '${python_bin}' to python binary."
    exit 1
fi
