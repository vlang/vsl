# Plottable adapters

Use the generic `plot.Plottable` interface to turn a VSL `Graph` or ML model
into a `plot.Plot` without extracting arrays by hand. Data extraction is
separate from rendering, so this example runs on a headless host and never
opens a browser.

Run it from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/plot_plottable/main.v
```

See the [`vsl.plot` API](../../plot/README.md) for the adapter contract and the
list of built-in types.
