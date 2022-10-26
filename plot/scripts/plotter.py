import argparse
import os
import json
import plotly.graph_objects as go
import numpy as np


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


def is_valid_file(parser, arg):
    if not os.path.exists(arg):
        parser.error("The file %s does not exist!" % arg)
    else:
        return open(arg, "r")  # return an open file handle


parser = argparse.ArgumentParser(description="Run training")
parser.add_argument(
    "--data",
    dest="data",
    required=True,
    help="input file with data",
    metavar="FILE",
    type=lambda x: is_valid_file(parser, x),
)
parser.add_argument(
    "--layout",
    dest="layout",
    required=True,
    help="input file with layout",
    metavar="FILE",
    type=lambda x: is_valid_file(parser, x),
)

args = parser.parse_args()

# Read data json file.
data = json.load(args.data)

# Read layout json file.
layout = json.load(args.layout)
# If there is no range specified, leave it as None
# and let Plotly handle it.
for ax in ['x', 'y']:
    if f'{ax}axis' in layout:
        if 'range' in layout[f'{ax}axis']:
            if len(layout[f'{ax}axis']['range']) != 2:
                layout[f'{ax}axis']['range'] = None

# Map vsl.plot.TraceType enum to Plotly objects.
type_map = {
    0: go.Scatter,
    1: go.Pie,
    2: go.Heatmap,
    3: go.Surface,
    4: go.Scatter3d,
    5: go.Bar,
    6: go.Histogram
}


# List of traces to be plotted.
plot_data = []
custom_keys = ["x_str"]

for trace in data:
    trace_type = trace.pop("trace_type")

    # Remove all JSON keys not accepted by
    # Plotly.
    accepted = dir(type_map[trace_type]) + custom_keys
    keys = list(trace.keys())
    for k in keys:
        if k not in accepted:
            trace.pop(k)

    # oh god why. remove empty keys
    trace = remove_key(trace, "marker", "size")
    trace = remove_key(trace, "marker", "color")
    trace = remove_key(trace, "line", "size")
    trace = remove_key(trace, "line", "color")
    trace = remove_key(trace, "line")
    trace = remove_key(trace, "name")
    trace = remove_key(trace, "mode")
    trace = remove_key(trace, "text")
    trace = remove_key(trace, "x")
    trace = remove_key(trace, "y")
    trace = remove_key(trace, "z")

    if trace_type == 1:
        if "marker" in trace:
            trace["marker"].pop("opacity")
            trace["marker"].pop("colorscale")

    if "x_str" in trace:
        if trace_type == 5:
            trace["x"] = trace["x_str"]
        trace.pop("x_str")

    # Since I can only pass [][]f64 to Trace.z,
    # I must flatten it when dealing with 3D scatters
    # (and possibly other 3D plots?).
    if trace_type == 4:
        trace["z"] = np.array(trace["z"]).flatten()

    plot_data.append(type_map[trace_type](trace))

fig = go.Figure(data=plot_data, layout=go.Layout(layout))
fig.show()
