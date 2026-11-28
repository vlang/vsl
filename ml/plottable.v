module ml

import vsl.plot

// The model types already expose get_plotter for data extraction. Implementing
// plot.Plottable here (rather than in vsl.plot) avoids an import cycle, since
// the ML module imports the plot module.

// to_plot returns the scatter plot of the fitted K-means model.
pub fn (o &Kmeans) to_plot() &plot.Plot {
	return o.get_plotter()
}

// to_plot returns the plot of the fitted KNN model.
pub fn (o &KNN) to_plot() &plot.Plot {
	return o.get_plotter()
}

// to_plot returns the data and fitted line for the regression model.
pub fn (o &LinReg) to_plot() &plot.Plot {
	return o.get_plotter()
}

// to_plot returns the data and decision boundary for the classifier.
pub fn (o &LogReg) to_plot() &plot.Plot {
	return o.get_plotter()
}
