# VSL Examples Collection 📚

Welcome to the VSL Examples Directory! This comprehensive collection demonstrates the full
capabilities of the V Scientific Library through practical, well-documented examples. Each
example is designed to showcase specific features while providing clear learning paths for
both beginners and advanced users.

## 🆕 What's New

### Latest Plotting Enhancements (2024-2025)

**Phase 1: Core Plot Types**
- ✅ Line charts with time series support
- ✅ Box plots for statistical analysis  
- ✅ Violin plots for distribution visualization
- ✅ Contour plots for topographical data
- ✅ Waterfall charts for financial analysis
- ✅ Sunburst charts for hierarchical data
- ✅ Treemap charts for nested data
- ✅ Candlestick charts for OHLC financial data
- ✅ Funnel charts for conversion analysis
- ✅ Radar/Polar charts for multi-dimensional comparison

**Phase 2: Advanced Analytics**
- ✅ 2D Histograms for bivariate analysis
- ✅ Parallel Coordinates for high-dimensional data
- ✅ Sankey Diagrams for flow visualization
- ✅ Choropleth Maps for geographic data
- ✅ Scatter Mapbox for location-based plots

**New Export Capabilities**
- ✅ **Direct PNG/PDF/SVG export** without ephemeral web server
- ✅ Multiple rendering engines (Puppeteer, Playwright, Chromium)
- ✅ High-resolution and custom format support
- ✅ Perfect for automation and batch processing

## 🎯 Quick Start Guide

### Prerequisites

1. **V Compiler**: Download from [vlang.io](https://vlang.io)
2. **VSL Library**: Follow the [installation guide](https://github.com/vlang/vsl#-installation--quick-start)
3. **Optional Dependencies**: Some examples require additional libraries (documented per example)

### Running Examples

```sh
# Navigate to any example directory
cd examples/plot_scatter

# Run the example
v run main.v

# For examples with custom dependencies
v -cflags <flags> run main.v
```

### 📖 Learning Path

**Beginners**: Start with → `plot_scatter` → `plot_line_timeseries` → `plot_bar` → `data_analysis_example`

**Intermediate**: Explore → `plot_box_statistics` → `plot_violin_distributions` → `ml_linreg_plot` → `fft_plot_example`

**Advanced Plotting**: Try → `plot_sunburst_hierarchy` → `plot_choropleth_population` → `plot_sankey_energy` → `plot_export_png`

**Machine Learning**: Progress → `ml_kmeans` → `ml_linreg_plot` → `ml_sentiment_analysis`

**Scientific Computing**: Dive into → `fft_plot_example` → `deriv_example` → `mpi_basic_example`

## Machine Learning Examples 🤖

| Example                                          | Description                                             |
| ------------------------------------------------ | ------------------------------------------------------- |
| [ml_kmeans](./ml_kmeans)                         | Example demonstrating the K-means clustering algorithm. |
| [ml_sentiment_analysis](./ml_sentiment_analysis) | Example for sentiment analysis using machine learning.  |
| [ml_linreg01](./ml_linreg01)                     | Basic linear regression example.                        |
| [ml_linreg02](./ml_linreg02)                     | Advanced linear regression example.                     |
| [ml_linreg_plot](./ml_linreg_plot)               | Linear regression with plotting.                        |
| [ml_kmeans_plot](./ml_kmeans_plot)               | K-means clustering with plotting.                       |
| [ml_knn_plot](./ml_knn_plot)                     | K-Nearest Neighbors algorithm with plotting.            |

## Plotting Examples 📊

### Core Plot Types

| Example                                                                      | Description                                 |
| ---------------------------------------------------------------------------- | ------------------------------------------- |
| [plot_scatter](./plot_scatter)                                               | Basic scatter plot example.                 |
| [plot_line_timeseries](./plot_line_timeseries)                               | Time series line chart plotting.            |
| [plot_bar](./plot_bar)                                                       | Basic bar plot example.                     |
| [plot_histogram](./plot_histogram)                                           | Example showing how to create a histogram.  |
| [plot_pie](./plot_pie)                                                       | Pie chart plotting example.                 |
| [plot_basic_heatmap](./plot_basic_heatmap)                                   | Basic heatmap example.                      |
| [plot_heatmap_golden_ratio](./plot_heatmap_golden_ratio)                     | Heatmap example with the golden ratio.      |
| [plot_scatter3d_1](./plot_scatter3d_1)                                       | 3D scatter plot example 1.                  |
| [plot_scatter3d_2](./plot_scatter3d_2)                                       | 3D scatter plot example 2.                  |
| [plot_scatter3d_easing](./plot_scatter3d_easing)                             | 3D scatter plot with easing.                |
| [plot_saddle_surface](./plot_saddle_surface)                                 | Plotting a saddle surface.                  |
| [plot_ripple_surface](./plot_ripple_surface)                                 | Plotting a ripple surface.                  |
| [plot_sin_cos_surface](./plot_sin_cos_surface)                               | Plotting the sine and cosine surface.       |
| [plot_surface](./plot_surface)                                               | 3D surface plotting example.                |
| [plot_surface_easing](./plot_surface_easing)                                 | 3D surface with animation easing.           |

### Statistical & Distribution Charts

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_box_statistics](./plot_box_statistics)               | Box plot for statistical analysis.          |
| [plot_violin_distributions](./plot_violin_distributions)   | Violin plot for distribution visualization. |
| [plot_contour_topography](./plot_contour_topography)       | Contour plot for topographical data.        |
| [plot_histogram2d_correlation](./plot_histogram2d_correlation) | 2D histogram for correlation analysis.   |

### Business & Financial Charts

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_waterfall_financial](./plot_waterfall_financial)     | Waterfall chart for financial analysis.     |
| [plot_candlestick_stocks](./plot_candlestick_stocks)       | Candlestick chart for stock data.           |
| [plot_funnel_conversion](./plot_funnel_conversion)         | Funnel chart for conversion analysis.       |

### Hierarchical & Network Charts

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_sunburst_hierarchy](./plot_sunburst_hierarchy)       | Sunburst chart for hierarchical data.       |
| [plot_treemap_portfolio](./plot_treemap_portfolio)         | Treemap chart for portfolio visualization.  |
| [plot_sankey_energy](./plot_sankey_energy)                 | Sankey diagram for energy flow analysis.    |

### Advanced Analytics

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_radar_performance](./plot_radar_performance)         | Radar chart for multi-dimensional analysis. |
| [plot_parcoords_analysis](./plot_parcoords_analysis)       | Parallel coordinates for high-dimensional data. |

### Geographic & Mapping

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_choropleth_population](./plot_choropleth_population) | Choropleth map for geographic data.         |
| [plot_scattermapbox_cities](./plot_scattermapbox_cities)   | Scatter plot on mapbox for location data.   |

### Export & Automation

| Example                                                     | Description                                 |
| ----------------------------------------------------------- | ------------------------------------------- |
| [plot_export_png](./plot_export_png)                       | **Direct PNG/PDF/SVG export without server.** |

### Styling & Customization

| Example                                                                      | Description                                 |
| ---------------------------------------------------------------------------- | ------------------------------------------- |
| [plot_line_axis_titles](./plot_line_axis_titles)                             | Line plot with axis titles.                 |
| [plot_scatter_with_annotations](./plot_scatter_with_annotations)             | Scatter plot with annotations.              |
| [plot_annotated_pie_chart](./plot_annotated_pie_chart)                       | Annotated pie chart example.                |
| [plot_grouped_bar_chart](./plot_grouped_bar_chart)                           | Grouped bar chart plotting example.         |
| [plot_scatter_with_bars](./plot_scatter_with_bars)                           | Scatter plot with bars.                     |
| [plot_line_plot_with_areas](./plot_line_plot_with_areas)                     | Line plot with shaded areas.                |
| [plot_scatter_with_regression](./plot_scatter_with_regression)               | Scatter plot with regression line.          |
| [plot_bubble_chart](./plot_bubble_chart)                                     | Bubble chart plotting example.              |
| [plot_shaded_area_sin](./plot_shaded_area_sin)                               | Shaded area plot of the sine function.      |
| [plot_scatter_easing](./plot_scatter_easing)                                 | Scatter plot with animation easing.         |
| [plot_scatter_colorscale](./plot_scatter_colorscale)                         | Scatter plot with custom color scaling.     |
| [plot_scatter_annotations_fixed](./plot_scatter_annotations_fixed)           | Clean annotations without unwanted arrows.  |
| [plot_scatter_with_histogram](./plot_scatter_with_histogram)                 | Scatter plot combined with histogram.       |
| [plot_json_export](./plot_json_export)                                       | Export plot data to JSON format.            |

### Script Mode Examples

| Example                                                                      | Description                                 |
| ---------------------------------------------------------------------------- | ------------------------------------------- |
| [plot_script_mode_ac_signal](./plot_script_mode_ac_signal)                   | AC signal plotting in script mode.          |
| [plot_script_mode_simple_plot](./plot_script_mode_simple_plot)               | Simple plot in script mode.                 |
| [plot_script_mode_three_phase_signal](./plot_script_mode_three_phase_signal) | Three-phase signal plotting in script mode. |

## Mathematical and Scientific Computation Examples 🔢

| Example                                            | Description                                                       |
| -------------------------------------------------- | ----------------------------------------------------------------- |
| [fft_plot_example](./fft_plot_example)             | Example demonstrating Fast Fourier Transform (FFT) with plotting. |
| [diff_example](./diff_example)                     | Differentiation example.                                          |
| [prime_factorization](./prime_factorization)       | Prime factorization example.                                      |
| [roots_bisection_solver](./roots_bisection_solver) | Root finding using the bisection method.                          |
| [deriv_example](./deriv_example)                   | Derivative calculation example.                                   |

## Geometry Module Examples 📐

| Example                                            | Description                                                       |
| -------------------------------------------------- | ----------------------------------------------------------------- |
| [gm_basic_geometry](./gm_basic_geometry)           | Fundamental 3D geometry operations.                               |
| [gm_advanced_analysis](./gm_advanced_analysis)     | Advanced geometric analysis techniques.                           |
| [gm_distance_analysis](./gm_distance_analysis)     | Distance calculation and shape analysis.                          |
| [gm_spatial_binning](./gm_spatial_binning)         | Spatial indexing and binning systems.                             |
| [gm_geometry_playground](./gm_geometry_playground) | Interactive geometry exploration.                                 |
| [gm_trajectory_simulation](./gm_trajectory_simulation) | Motion and trajectory analysis.                               |

## Noise & Signal Processing Examples 🌊

| Example                                            | Description                                                       |
| -------------------------------------------------- | ----------------------------------------------------------------- |
| [noise_fractal_2d](./noise_fractal_2d)            | 2D fractal noise generation.                                      |
| [noise_simplex_2d](./noise_simplex_2d)            | 2D simplex noise generation.                                      |

## Data Analysis Examples 📈

| Example                                          | Description                                         |
| ------------------------------------------------ | --------------------------------------------------- |
| [data_analysis_example](./data_analysis_example) | Basic data analysis example.                        |
| [io_h5_relax](./io_h5_relax)                     | Example demonstrating HDF5 I/O for relaxation data. |
| [io_h5_dataset](./io_h5_dataset)                 | Example demonstrating HDF5 I/O for datasets.        |

## Iteration and Lazy Generation Examples 🔄

| Example                                        | Description                                 |
| ---------------------------------------------- | ------------------------------------------- |
| [iter_lazy_generation](./iter_lazy_generation) | Example of lazy generation using iterators. |

## Parallel and Distributed Computing Examples 🌐

| Example                                  | Description                          |
| ---------------------------------------- | ------------------------------------ |
| [mpi_bcast_example](./mpi_bcast_example) | Example demonstrating MPI broadcast. |
| [mpi_basic_example](./mpi_basic_example) | Basic MPI example.                   |

## OpenCL Examples 🖥️

| Example                                                                | Description                      |
| ---------------------------------------------------------------------- | -------------------------------- |
| [vcl_opencl_fractals_one_argument](./vcl_opencl_fractals_one_argument) | Fractal generation using OpenCL. |
| [vcl_opencl_image_example](./vcl_opencl_image_example)                 | Image processing using OpenCL.   |
| [vcl_opencl_basic](./vcl_opencl_basic)                                 | Basic OpenCL example.            |

## Miscellaneous Examples 🌟

| Example                            | Description                                      |
| ---------------------------------- | ------------------------------------------------ |
| [la_triplet01](./la_triplet01)     | Example demonstrating linear algebra operations. |
| [dist_histogram](./dist_histogram) | Distribution histogram example.                  |

### 📋 Important Guidelines ⚠️

**Total Examples**: This collection includes **75+ working examples** covering all VSL modules.

- **Documentation First**: Each example includes a detailed `README.md` - always read it
  before running
- **Dependencies**: Check for system requirements in individual example READMEs
- **Output**: Examples may generate plots, files, or terminal output - check the
  documentation for expected results
- **Troubleshooting**: If an example fails, verify all prerequisites are installed and refer to the main [VSL documentation](https://vlang.github.io/vsl)

### 🔧 Building & Compilation

Most examples work with standard compilation:

```sh
v run main.v
```

For performance-critical examples with optional backends:

```sh
# With OpenBLAS
v -cflags -lblas run main.v

# With OpenMPI
v -cflags -lmpi run main.v
```

### 🤝 Contributing Examples

We welcome new examples! Please ensure your contributions:

- Include comprehensive documentation
- Follow existing naming conventions
- Provide clear, commented code
- Include expected output samples
- Test across different platforms

See the [Contributing Guide](../CONTRIBUTING.md) for detailed guidelines.
