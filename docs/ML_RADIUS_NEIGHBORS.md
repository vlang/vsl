# Exact radius-neighbor queries

`vsl.ml.radius_neighbors(training, queries, radius, metric)` returns every
training-row index and distance within `radius` for each query row. It supports
the `.euclidean` and `.manhattan` metrics.

The radius must be finite and non-negative. The boundary is inclusive, so a
training row whose computed distance is exactly the radius is included. Each
query's matches are sorted by distance and then by original training-row index;
duplicate training rows remain distinct. The outer result rows preserve the
input query order.

A query with no matches has an empty indices row and an empty distances row. An
empty query batch produces no result rows. Training data must contain at least
one row and one feature; supplied rows must have consistent widths and finite
features. Non-finite computed distances are rejected.

This is an exact brute-force query. It scans training rows for each query and
collects only matching candidates rather than building a query-by-training
distance matrix.

See the [radius-neighbor example](../examples/ml_radius_neighbors/README.md).
