module plot

// Plottable is implemented by VSL values that can describe themselves as a
// plot. It keeps data extraction separate from rendering: calling to_plot
// never opens a browser or writes a file, so adapters work on headless hosts.
pub interface Plottable {
	to_plot() &Plot
}

// render returns the plot described by a Plottable value. It is the generic
// entry point for callers that accept any Plottable VSL type.
pub fn render(value Plottable) &Plot {
	return value.to_plot()
}
