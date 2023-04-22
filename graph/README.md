# Graph theory structures and algorithms

This package implements algorithms for handling graphs and solving problems such as shortest path
finding. It also implements an algorithm to solve the assignment problem.

## Graph representation

In `graph`, directed graphs are mainly defined by edges. A weight can be assigned to each edge as
well. For example, the graph below:

```console
          [10]
     0 ––––––––→ 3      numbers in parentheses
     |    (1)    ↑      indicate edge ids
  [5]|(0)        |
     |        (3)|[1]
     ↓    (2)    |      numbers in brackets
     1 ––––––––→ 2      indicate weights
          [3]
```

is defined with the following code:

```v
module main

import vsl.graph

edges := [[0, 1], [0, 3], [1, 2], [2, 3]]
weights_e := [5.0, 10.0, 3.0, 1.0]
verts := [][]f64{}
weights_v := []f64{}
g := graph.new_graph(edges, weights_e, verts, weights_v)
// print distance matrix
print(g.str_dist_matrix())
```

Vertex coordinates can be specified as well. Furthermore, weights can be assigned to vertices. These
are useful when computing distances, for example.

## Floyd-Warshall algorithm to compute shortest paths

The `shortest_paths` method of `Graph` computes the shortest paths using the Floyd-Warshall
algorithm. For example, the graph above has the following distances matrix:

```console
       [10]
    0 ––––––→ 3            numbers in brackets
    |         ↑            indicate weights
[5] |         | [1]
    ↓         |
    1 ––––––→ 2
        [3]                ∞ means that there are no
                           connections from i to j
graph:  j= 0  1  2  3
           -----------  i=
           0  5  ∞ 10 |  0  ⇒  w(0→1)=5, w(0→3)=10
           ∞  0  3  ∞ |  1  ⇒  w(1→2)=3
           ∞  ∞  0  1 |  2  ⇒  w(2→3)=1
           ∞  ∞  ∞  0 |  3
```

After running the `shortest_paths` command,
paths from source (s) to destination (t) can be extracted
with the `path` method.

### Example: Small graph

```console
         [10]
    0 ––––––––→ 3      numbers in parentheses
    |    (1)    ↑      indicate edge ids
 [5]|(0)        |
    |        (3)|[1]
    ↓    (2)    |      numbers in brackets
    1 ––––––––→ 2      indicate weights
         [3]
```

```v
module main

import vsl.graph

// initialise graph
edges := [[0, 1], [0, 3], [1, 2], [2, 3]]
weights_e := [5.0, 10.0, 3.0, 1.0]
verts := [][]f64{}
weights_v := []f64{}
g := graph.new_graph(edges, weights_e, verts, weights_v)
// compute paths
g.shortest_paths(.fw)
// print shortest path from 0 to 2
print(g.path(0, 2))
// print shortest path from 0 to 3
print(g.path(0, 3))
// print distance matrix
print(g.str_dist_matrix())
```
