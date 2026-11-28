module graph

import vsl.plot

// to_plot renders the graph as vertex markers connected by edge lines. Only
// the first two vertex coordinates are used. Vertices with fewer than two
// coordinates and edges that reference missing vertices are skipped. Calling
// this method never opens a browser or writes a file.
pub fn (g &Graph) to_plot() &plot.Plot {
	mut plt := plot.Plot.new()
	plt.layout(title: 'Graph')

	mut xs := []f64{}
	mut ys := []f64{}
	for vertex in g.verts {
		if vertex.len < 2 {
			continue
		}
		xs << vertex[0]
		ys << vertex[1]
	}
	if xs.len > 0 {
		plt.scatter(
			name: 'vertices'
			x:    xs
			y:    ys
			mode: 'markers'
		)
	}

	for edge in g.edges {
		if edge.len < 2 {
			continue
		}
		from := edge[0]
		to := edge[1]
		if from < 0 || to < 0 || from >= g.verts.len || to >= g.verts.len {
			continue
		}
		if g.verts[from].len < 2 || g.verts[to].len < 2 {
			continue
		}
		plt.line(
			name: '${from} - ${to}'
			x:    [g.verts[from][0], g.verts[to][0]]
			y:    [g.verts[from][1], g.verts[to][1]]
		)
	}
	return plt
}
