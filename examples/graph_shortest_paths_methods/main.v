module main

import vsl.graph

fn main() {
	println('== shortest paths methods comparison ==')
	println('')

	// Weighted directed graph
	weighted := graph.Graph.new([[0, 1], [0, 3], [1, 2], [2, 3],
		[3, 4], [1, 4]], [5.0, 11.0, 3.0, 1.0, 2.0, 20.0], [], [])

	fw := weighted.shortest_paths(.fw)
	dj := weighted.shortest_paths(.dijkstra)

	println('weighted graph (distance objective)')
	print_method_result('floyd-warshall', fw, 0, 4)
	print_method_result('dijkstra', dj, 0, 4)

	println('')
	println('hop-based graph (unweighted shortest path objective)')
	// In this graph, BFS favors fewer edges while weighted methods favor smaller sum of weights.
	hop_graph := graph.Graph.new([[0, 1], [1, 5], [0, 2], [2, 3],
		[3, 4], [4, 5]], [50.0, 50.0, 1.0, 1.0, 1.0, 1.0], [], [])
	bfs := hop_graph.shortest_paths(.bfs)
	fw_hop := hop_graph.shortest_paths(.fw)

	print_method_result('bfs (hops)', bfs, 0, 5)
	print_method_result('floyd-warshall (weights)', fw_hop, 0, 5)
}

fn print_method_result(name string, g graph.Graph, s int, t int) {
	p := g.path(s, t)
	println('  ${name:28s} path=${p} dist=${g.dist[s][t]:.4f}')
}
