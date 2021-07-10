# TODO: write actually good code.

import plotly.graph_objects as go
import numpy
import json
import os
import sys
import pwd
import numpy as np

# Get username to access .vmodules
user = pwd.getpwuid(os.getuid()).pw_name

# Read data json (vsl.plot generates it).
data_json_path = f'/home/{user}/.vmodules/vsl/plot/data.json'
if not os.path.isfile(data_json_path):
	raise Exception('data.json not found. Please create a valid, Plotly compliant, graph object.')
	sys.exit(1)
dt = json.load(open(data_json_path, 'r'))

# Read layout json (vsl.plot generates it).
layout_json_path = f'/home/{user}/.vmodules/vsl/plot/layout.json'
if not os.path.isfile(layout_json_path):
	raise Exception('layout.json not found. Please create a valid, Plotly compliant, layout object.')
	sys.exit(1)
lyt = json.load(open(layout_json_path, 'r'))

# Map vsl.plot.TraceType enum to Plotly objects.
type_map = {
	0: go.Scatter,
	1: go.Pie,
	2: go.Heatmap,
	3: go.Surface,
	4: go.Scatter3d,
	5: go.Bar,
}

# Remove empty properties as to let Plotly
# use default ones. If empty_subkey is provided,
# it will only remove empty_subkey from d[key]
# (if present and empty). If it is not provided,
# then it removes key from d if key is in d and
# d[key] is empty.
def remove_key(d, key, empty_subkey=None):
	r = d
	if key in r:
		if empty_subkey is not None:
			if empty_subkey in r[key]:
				if not len(r[key][empty_subkey]):
					r[key].pop(empty_subkey)
		else:
			if not len(r[key]):
				r.pop(key)
	return r

# List of traces to be plotted.
plot_data = []

custom_keys = ['x_str']

for trace in dt:
	trace_type = trace.pop('trace_type')

	# Remove all JSON keys not accepted by
	# Plotly.
	accepted = dir(type_map[trace_type]) + custom_keys
	keys = list(trace.keys())
	for k in keys:
		if k not in accepted:
			trace.pop(k)

	# oh god why. remove empty keys
	trace = remove_key(trace, 'marker', 'size')
	trace = remove_key(trace, 'marker', 'color')
	trace = remove_key(trace, 'line', 'size')
	trace = remove_key(trace, 'line', 'color')
	trace = remove_key(trace, 'line')
	trace = remove_key(trace, 'name')
	trace = remove_key(trace, 'mode')
	trace = remove_key(trace, 'text')
	trace = remove_key(trace, 'x')
	trace = remove_key(trace, 'y')
	trace = remove_key(trace, 'z')

	if trace_type == 1:
		if 'marker' in trace:
			trace['marker'].pop('opacity')
			trace['marker'].pop('colorscale')

	if 'x_str' in trace:
		if trace_type == 5:
			trace['x'] = trace['x_str']
		trace.pop('x_str')

	# Since I can only pass [][]f64 to Trace.z,
	# I must flatten it when dealing with 3D scatters
	# (and possibly other 3D plots?).
	if trace_type == 4:
		trace['z'] = np.array(trace['z']).flatten()

	plot_data.append(type_map[trace_type](trace))

fig = go.Figure(data=plot_data, layout=go.Layout(lyt))
fig.show()
