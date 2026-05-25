# graph_shortest_paths_methods

Representative comparison of shortest-path methods available in `vsl.graph`.

## What this example shows

- `fw` (Floyd-Warshall): all-pairs shortest paths minimizing **total edge weight**
- `dijkstra`: all-pairs via repeated single-source Dijkstra, same objective as above
- `bfs`: all-pairs minimizing **number of hops** (ignores edge weights)

This helps choose the right method depending on whether your objective is
travel cost (weights) or traversal depth (hops).

## Run

```sh
v run examples/graph_shortest_paths_methods/main.v
```

## Typical output interpretation

- In weighted graphs, `fw` and `dijkstra` should agree on path and distance.
- In mixed graphs, `bfs` may return a different path because it optimizes hops.
