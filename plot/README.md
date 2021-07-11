# VSL Plot

> This is in a very early stage of development so issues are to be expected.
The lack of features is the major problem right now, but these are slowly but
surely going to be added. If you find any problem, please file an issue and
we will try to solve it as soon as possible. Any suggestion is welcome!

`vsl.plot` follows the structure of
[Plotly's graph_objects](https://plotly.com/python/graph-objects/).
Check the examples folder and compare it to Plotly's Python examples
for a better understanding.

Supported Graph types:

- scatter
- pie
- heatmap
- surface
- scatter3d
- bar

## Examples

### Bar plot

```v
module main

import vsl.plot

fn main() {
	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .bar
		x_str: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724., 1379217184, 331989449, 271350000, 225200000]
	)
	plt.set_layout(
		title: 'Countries by population'
	)
	plt.show() or { panic(err) }
}
```

> Output

<div align="center">
<p>
    <img
        style="width: 400px"
        width="200"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/bar.png?sanitize=true"
    >
</p>
</div>

### Pie plot

```v
module main

import vsl.plot

fn main() {
	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .pie
		labels: ['Nitrogen', 'Oxygen', 'Argon', 'Other']
		values: [78., 21, 0.9, 0.1]
		pull: [0., 0.1, 0, 0]
		hole: 0.25
	)
	plt.set_layout(
		title: 'Gases in the atmosphere'
		width: 750
		height: 750
	)
	plt.show() or { panic(err) }
}
```

> Output

<div align="center">
<p>
    <img
        style="width: 400px"
        width="200"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/pie.png?sanitize=true"
    >
</p>
</div>

### Scatter plot

```v
module main

import vsl.plot
import vsl.util

fn main() {
	y := [
		0.,
		1,
		3,
		1,
		0,
		-1,
		-3,
		-1,
		0,
		1,
		3,
		1,
		0,
	]
	x := util.arange(y.len).map(f64(it))

	// Expected output:
	//	  .       .
	//  -' '-   -' '_
	//       '.'

	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .scatter
		x: x
		y: y
		mode: 'lines+markers'
		marker: {
			size: []f64{len: x.len, init: 10.}
			color: []string{len: x.len, init: '#FF0000'}
		}
		line: {
			color: '#FF0000'
		}
	)
	plt.set_layout(
		title: 'Scatter plot example'
	)
	plt.show() or { panic(err) }
}
```

> Output

<div align="center">
<p>
    <img
        style="width: 400px"
        width="200"
        src="https://raw.githubusercontent.com/vlang/vsl/master/plot/static/scatter.png?sanitize=true"
    >
</p>
</div>
