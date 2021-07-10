#!/bin/bash
usr=$(whoami)
cd "/home/$usr/.vmodules/vsl/plot"

which python &>/dev/null

if [[ $? -eq 1 ]]; then
	echo "Please install Python 3 and link it to /bin/python."
	exit
fi

pyver=$(python -c "import platform; print(str(platform.python_version()).split('.')[0])")

echo "$pyver"

if [[ $pyver != "3" ]]; then
	echo "The detected Python version is < 3.0.0,
please update your Python version to 3+. If you already have
Python 3+ under python3, please link python3 to /bin/python."
	exit
fi

python -m venv plotvenv
source "/home/$usr/.vmodules/vsl/plot/plotvenv/bin/activate"
pip install plotly numpy pandas
deactivate
