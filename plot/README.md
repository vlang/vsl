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

[bar plot example](https://github.com/vlang/vsl/blob/master/examples/plot_bar)

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

[heatmap plot example](https://github.com/vlang/vsl/blob/master/examples/plot_heatmap)

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

[histogram plot example](https://github.com/vlang/vsl/blob/master/examples/plot_histogram)

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

[pie plot example](https://github.com/vlang/vsl/blob/master/examples/plot_pie)

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

[scatter plot example](https://github.com/vlang/vsl/blob/master/examples/plot_scatter)

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

[scatter3d plot example](https://github.com/vlang/vsl/blob/master/examples/plot_scatter3d)

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
