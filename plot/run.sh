#!/bin/bash
f=$0
b_name=${f%/*}

if [ ! -d "$b_name/plotvenv" ]; then
	echo "Creating plotly virtualenv..."
	bash "$b_name/create-venv.sh"
fi

source "$b_name/plotvenv/bin/activate"
python "$b_name/plotter.py"
