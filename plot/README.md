# VSL Plot

> This is in a very early stage of development so issues are to be expected.
> The lack of features is the major problem right now, but these are slowly but
> surely going to be added. If you find any problem, please file an issue and
> we will try to solve it as soon as possible. Any suggestion is welcome!

This library implements high-level functions to generate plots and drawings.
Although we use Python/Plotly, the goal is to provide a convenient
V library that is different than Plotly. The difference happens
because we want convenience for the V developer while getting the
fantastic quality of Plotly grinning.

Internally, we use Plotly via a Python 3 script. First, we generate a
JSON files in a directory under `$VMODULES/vsl/plot`, and then
we call python3 using V's `os.execute`. The JSON file is then read
by Plotly and the plot is generated.

`vsl.plot` follows the structure of
[Plotly's graph_objects](https://plotly.com/python/graph-objects/).
Check the examples folder and compare it to Plotly's Python examples
for a better understanding.

## Dependencies

- [Python 3](https://www.python.org/)

## Supported Graph Types

- Bar
- Heatmap
- Histogram
- Pie
- Scatter
- Scatter 3D
- Surface

## Examples

### Bar plot

[examples/bar.v](https://github.com/vlang/vsl/blob/master/plot/examples/bar.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/bar.png?sanitize=true"
    >
</p>
</div>

### Heatmap plot

[examples/heatmap.v](https://github.com/vlang/vsl/blob/master/plot/examples/heatmap.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/heatmap.png?sanitize=true"
    >
</p>
</div>

### Histogram plot

[examples/histogram.v](https://github.com/vlang/vsl/blob/master/plot/examples/histogram.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/histogram.png?sanitize=true"
    >
</p>
</div>

### Pie plot

[examples/pie.v](https://github.com/vlang/vsl/blob/master/plot/examples/pie.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/pie.png?sanitize=true"
    >
</p>
</div>

### Scatter plot

[examples/scatter.v](https://github.com/vlang/vsl/blob/master/plot/examples/scatter.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/scatter.png?sanitize=true"
    >
</p>
</div>

### Scatter 3D plot

[examples/scatter3d.v](https://github.com/vlang/vsl/blob/master/plot/examples/scatter3d.v)

> Output

<div align="center">
<p>
    <img
        style="width: 50%"
  width="80%"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/scatter3d.png?sanitize=true"
    >
</p>
</div>
