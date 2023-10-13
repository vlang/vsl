import argparse
import os
import json
import plotly.graph_objects as go


def remove_empty_keys(d):
    """
    Recursively remove empty keys (both keys with empty values
    and empty lists/dictionaries).
    If a key is empty, it is removed from the dictionary.
    If a key is a list/dictionary, it is recursively processed.
    """
    result = d
    for k in list(result.keys()):
        if isinstance(result[k], dict):
            result[k] = remove_empty_keys(result[k])
            if not len(result[k]):
                result.pop(k)
        elif isinstance(result[k], list):
            if not len(result[k]):
                result.pop(k)
        else:
            if not result[k]:
                result.pop(k)
    return result


def is_valid_file(parser, arg):
    """
    Check if the provided file path exists.
    """
    if not os.path.exists(arg):
        parser.error("The file %s does not exist!" % arg)
    else:
        return open(arg, "r")  # return an open file handle


def load_json_file(file_handle):
    """
    Load and return JSON data from a file handle.
    """
    return json.load(file_handle)


def process_layout_range(layout, axis):
    """
    Ensure that the layout range is specified correctly.
    """
    if f'{axis}axis' in layout:
        if 'range' in layout[f'{axis}axis']:
            if len(layout[f'{axis}axis']['range']) != 2:
                layout[f'{axis}axis']['range'] = None


def map_trace_type_to_plotly_object(trace_type):
    """
    Map vsl.plot.TraceType enum to Plotly objects.
    """
    type_map = {
        'scatter': go.Scatter,
        'pie': go.Pie,
        'heatmap': go.Heatmap,
        'surface': go.Surface,
        'scatter3d': go.Scatter3d,
        'bar': go.Bar,
        'histogram': go.Histogram
    }
    return type_map[trace_type]


def process_trace(trace):
    """
    Process a trace to ensure only accepted keys are present.
    """
    trace_type = trace.pop("trace_type")

    # Remove all JSON keys not accepted by Plotly.
    accepted = dir(map_trace_type_to_plotly_object(trace_type))
    keys = list(trace.keys())
    for k in keys:
        if k not in accepted:
            trace.pop(k)

    trace = remove_empty_keys(trace)

    return map_trace_type_to_plotly_object(trace_type)(trace)


def main():
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

    # Read data JSON file.
    data = load_json_file(args.data)

    # Read layout JSON file.
    layout = load_json_file(args.layout)

    # Ensure correct layout range specification.
    for axis in ['x', 'y']:
        process_layout_range(layout, axis)

    # List of traces to be plotted.
    plot_data = [process_trace(trace) for trace in data]

    fig = go.Figure(data=plot_data, layout=go.Layout(layout))
    fig.show()


if __name__ == "__main__":
    main()
