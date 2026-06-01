// Module graph implements solvers based on Graph theory
module graph

import strconv
import math
import vsl.errors
import vsl.util

// ShortestPaths lists the supported public values for this module.
pub enum ShortestPaths {
	fw       // FW: Floyd-Warshall method
	dijkstra // Dijkstra all-pairs (repeated single-source)
	bfs      // Breadth-first search all-pairs (unweighted shortest path in hops)
}

// Graph defines a graph structure

// Graph defines a public data structure for this module.

// Graph defines a public data structure for this module.
@[heap]
pub struct Graph {
pub:
	// input
	edges     [][]int // [nedges][2] edges (connectivity)
	weights_e []f64   // [nedges] weights of edges
	verts     [][]f64 // [nverts][ndim] vertices
	weights_v []f64   // [nverts] weights of vertices
	// auxiliary
	shares   map[int][]int // [nverts] edges sharing a vertex
	key2edge map[int]int   // maps (i,j) vertex to edge index
	dist     [][]f64       // [nverts][nverts] distances
	next     [][]int       // [nverts][nverts] next tree connection. -1 means no connection
}

// Graph.new initialises graph
// edges    -- [nedges][2] edges (connectivity)
// weights_e -- [nedges] weights of edges
// verts    -- [nverts][ndim] vertices
// weights_v -- [nverts] weights of vertices
pub fn Graph.new(edges [][]int, weights_e []f64, verts [][]f64, weights_v []f64) &Graph {
	mut key2edge := map[int]int{}
	mut shares := map[int][]int{}
	for k, edge in edges {
		i := edge[0]
		j := edge[1]
		shares = util.int_ints_map_append(shares, i, k)
		shares = util.int_ints_map_append(shares, j, k)
		key2edge[hash_edge_key(i, j)] = k
	}
	nv := shares.keys().len
	mut dist := [][]f64{len: nv, init: []f64{len: nv}}
	mut next := [][]int{len: nv, init: []int{len: nv}}
	return &Graph{
		edges:     edges
		weights_e: weights_e
		verts:     verts
		weights_v: weights_v
		shares:    shares
		key2edge:  key2edge
		dist:      dist
		next:      next
	}
}

// nverts returns the number of vertices
pub fn (g &Graph) nverts() int {
	return g.shares.keys().len
}

// get_edge performs a lookup on key2edge map and returs id of edge for given nodes ides
pub fn (g &Graph) get_edge(i int, j int) !int {
	key := hash_edge_key(i, j)
	if key in g.key2edge {
		return g.key2edge[key]
	}
	return errors.error('cannot find edge from ${i} to ${j}', .efailed)
}

/*
* shortest_paths computes the shortest paths in a graph defined as follows
 *
 *          [10]
 *       0 ––––––→ 3            numbers in brackets
 *       |         ↑            indicate weights
 *   [5] |         | [1]
 *       ↓         |
 *       1 ––––––→ 2
 *           [3]                ∞ means that there are no
 *                              connections from i to j
 *   graph:  j= 0  1  2  3
 *              -----------  i=
 *              0  5  ∞ 10 |  0  ⇒  w(0→1)=5, w(0→3)=10
 *              ∞  0  3  ∞ |  1  ⇒  w(1→2)=3
 *              ∞  ∞  0  1 |  2  ⇒  w(2→3)=1
 *              ∞  ∞  ∞  0 |  3
 *  Input:
 *   method -- FW: Floyd-Warshall method
*/
// shortest_paths exposes this operation as part of the public API.
pub fn (g &Graph) shortest_paths(method ShortestPaths) Graph {
	g2 := g.calc_dist()
	mut dist := g2.dist.clone()
	mut next := g2.next.clone()
	match method {
		.fw {
			dist, next = shortest_paths_fw(g2)
		}
		.dijkstra {
			dist, next = shortest_paths_dijkstra(g2)
		}
		.bfs {
			dist, next = shortest_paths_bfs(g2)
		}
	}

	return Graph{
		edges:     g2.edges
		weights_e: g2.weights_e
		verts:     g2.verts
		weights_v: g2.weights_v
		shares:    g2.shares
		key2edge:  g2.key2edge
		dist:      dist
		next:      next
	}
}

fn shortest_paths_fw(g Graph) ([][]f64, [][]int) {
	nv := g.dist.len
	mut dist := g.dist.clone()
	mut next := g.next.clone()
	for k := 0; k < nv; k++ {
		for i := 0; i < nv; i++ {
			for j := 0; j < nv; j++ {
				sum := dist[i][k] + dist[k][j]
				if dist[i][j] > sum {
					dist[i][j] = sum
					next[i][j] = next[i][k]
				}
			}
		}
	}
	return dist, next
}

fn shortest_paths_dijkstra(g Graph) ([][]f64, [][]int) {
	nv := g.dist.len
	mut all_dist := [][]f64{len: nv, init: []f64{len: nv, init: math.max_f64}}
	mut all_next := [][]int{len: nv, init: []int{len: nv, init: -1}}

	for s := 0; s < nv; s++ {
		mut visited := []bool{len: nv}
		mut prev := []int{len: nv, init: -1}
		mut dist := []f64{len: nv, init: math.max_f64}
		dist[s] = 0.0

		for _ in 0 .. nv {
			u := argmin_unvisited(dist, visited)
			if u < 0 || dist[u] == math.max_f64 {
				break
			}
			visited[u] = true
			neighbors := out_neighbors(g, u)
			for v in neighbors {
				w := g.dist[u][v]
				if w == math.max_f64 {
					continue
				}
				candidate := dist[u] + w
				if candidate < dist[v] {
					dist[v] = candidate
					prev[v] = u
				}
			}
		}

		all_dist[s] = dist.clone()
		for t := 0; t < nv; t++ {
			all_next[s][t] = first_hop_from_prev(s, t, prev)
		}
	}

	return all_dist, all_next
}

fn shortest_paths_bfs(g Graph) ([][]f64, [][]int) {
	nv := g.dist.len
	mut all_dist := [][]f64{len: nv, init: []f64{len: nv, init: math.max_f64}}
	mut all_next := [][]int{len: nv, init: []int{len: nv, init: -1}}

	for s := 0; s < nv; s++ {
		mut prev := []int{len: nv, init: -1}
		mut hops := []int{len: nv, init: -1}
		mut queue := []int{cap: nv}
		mut qhead := 0

		hops[s] = 0
		queue << s

		for qhead < queue.len {
			u := queue[qhead]
			qhead++
			neighbors := out_neighbors(g, u)
			for v in neighbors {
				if hops[v] != -1 {
					continue
				}
				hops[v] = hops[u] + 1
				prev[v] = u
				queue << v
			}
		}

		for t := 0; t < nv; t++ {
			if hops[t] >= 0 {
				all_dist[s][t] = f64(hops[t])
			}
			all_next[s][t] = first_hop_from_prev(s, t, prev)
		}
	}

	return all_dist, all_next
}

fn argmin_unvisited(dist []f64, visited []bool) int {
	mut best := -1
	mut best_dist := math.max_f64
	for i, d in dist {
		if !visited[i] && d < best_dist {
			best_dist = d
			best = i
		}
	}
	return best
}

fn out_neighbors(g Graph, u int) []int {
	mut neighbors := []int{}
	if u !in g.shares {
		return neighbors
	}
	for eid in g.shares[u] {
		edge := g.edges[eid]
		if edge[0] == u {
			neighbors << edge[1]
		}
	}
	return neighbors
}

fn first_hop_from_prev(s int, t int, prev []int) int {
	if s == t {
		return -1
	}
	if t < 0 || t >= prev.len {
		return -1
	}
	mut cur := t
	mut parent := prev[cur]
	if parent == -1 {
		return -1
	}
	for parent != s {
		cur = parent
		if cur < 0 || cur >= prev.len {
			return -1
		}
		parent = prev[cur]
		if parent == -1 {
			return -1
		}
	}
	return cur
}

// path returns the path from source (s) to destination (t)
// Note: shortest_paths method must be called first
pub fn (g &Graph) path(s int, t int) []int {
	s_next := g.next[s]
	n := s_next[t]
	if n < 0 {
		return []
	}
	mut p := [s]
	mut u := s
	for u != t {
		u_next := g.next[u]
		u = u_next[t]
		p << u
	}
	return p
}

// calc_dist computes distances beetween all vertices and initialises 'next' matrix
pub fn (g &Graph) calc_dist() Graph {
	mut dist := g.dist.clone()
	mut next := g.next.clone()
	verts := g.verts
	edges := g.edges
	weights_e := g.weights_e
	nv := dist.len
	for i := 0; i < nv; i++ {
		for j := 0; j < nv; j++ {
			if i == j {
				dist[i][j] = 0
			} else {
				dist[i][j] = math.max_f64
			}
			next[i][j] = -1
		}
	}
	for k, edge in edges {
		i := edge[0]
		j := edge[1]
		mut d := 1.0
		if verts.len != 0 {
			d = 0.0
			xa := verts[i]
			xb := verts[j]
			for dim := 0; dim < xa.len; dim++ {
				d += math.pow(xa[dim] - xb[dim], 2.0)
			}
			d = math.sqrt(d)
		}
		if weights_e.len != 0 {
			d *= weights_e[k]
		}
		dist[i][j] = d
		next[i][j] = j
		if dist[i][j] < 0 {
			errors.vsl_panic('distance between vertices cannot be negative: ${dist}[i][j]',
				.efailed)
		}
	}
	return Graph{
		edges:     g.edges
		weights_e: g.weights_e
		verts:     g.verts
		weights_v: g.weights_v
		shares:    g.shares
		key2edge:  g.key2edge
		dist:      dist
		next:      next
	}
}

// hash_edge_key creates a unique hash key identifying an edge
fn hash_edge_key(i int, j int) int {
	key := i + 10000001 * j
	return key
}

// str_dist_matrix returns a string representation of dist matrix
pub fn (g &Graph) str_dist_matrix() string {
	nv := g.dist.len
	mut maxlen := 0
	for i := 0; i < nv; i++ {
		for j := 0; j < nv; j++ {
			i_dist := g.dist[i]
			if i_dist[j] < math.max_f64 {
				i_dist_str := unsafe { strconv.v_sprintf('%g', i_dist[j]) }
				maxlen = int(math.max(maxlen, i_dist_str.len))
			}
		}
	}
	mut l := ''
	maxlen = int(math.max(3, maxlen)) + 1
	fmts := unsafe { strconv.v_sprintf('%%d', maxlen) }
	fmtn := unsafe { strconv.v_sprintf('%%%dg', maxlen) }
	for i := 0; i < nv; i++ {
		for j := 0; j < nv; j++ {
			i_dist := g.dist[i]
			if i_dist[j] < math.max_f64 {
				l += unsafe { strconv.v_sprintf(fmtn, i_dist[j]) }
			} else {
				l += unsafe { strconv.v_sprintf(fmts) } + '∞'
			}
		}
		l += '\n'
	}
	return l
}

// get_adj returns adjacency list as a compressed storage format for METIS
pub fn (g &Graph) get_adj() ([]int, []int) {
	nv := g.nverts()
	mut szadj := 0
	for vid := 0; vid < nv; vid++ {
		szadj += g.shares[vid].len // = number of connected vertices
	}
	mut xadj := []int{len: nv + 1}
	mut adjncy := []int{len: szadj}
	mut k := 0
	for vid := 0; vid < nv; vid++ {
		edges := g.shares[vid]
		for eid in edges {
			edge := g.edges[eid]
			mut other_vid := edge[0]
			if other_vid == vid {
				other_vid = edge[1]
			}
			adjncy[k] = other_vid
			k++
		}
		xadj[1 + vid] = xadj[vid] + edges.len
	}
	return xadj, adjncy
}
