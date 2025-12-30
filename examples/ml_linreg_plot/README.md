# Linear Regression with Plotting

This example demonstrates linear regression using VSL's machine learning module
combined with visualization.

## What You'll Learn

- Performing linear regression with VSL
- Preparing data for ML algorithms
- Visualizing regression results
- Understanding linear regression concepts

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/ml_linreg_plot

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive plot showing:

- **Data points**: Scatter plot of training data
- **Regression line**: Fitted linear regression line
- **Visualization**: Clear view of how well the model fits the data

## Code Walkthrough

### 1. Data Preparation

```v
import vsl.ml

x_matrix := [][]f64{} // Assume populated
y_vector := []f64{} // Assume populated
mut data := ml.Data.from_raw_xy_sep(x_matrix, y_vector)!
```

The `Data` struct holds features (X) and targets (Y) for machine learning.

### 2. Model Training

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.LinReg.new(mut data, 'linreg')
model.fit()
```

Linear regression finds the best-fit line through the data points.

### 3. Prediction and Visualization

```v ignore
import vsl.ml

mut model := ml.LinReg.new(mut data, 'linreg')  // Assume model is trained
x_test := [][]f64{}  // Assume populated
// predictions := model.predict(x_test)
// Plot data points and regression line
```

Results are visualized to show the model's fit.

## Mathematical Background

### Linear Regression

Linear regression finds a line **y = mx + b** that best fits the data by
minimizing the sum of squared errors:

**minimize: Σ(yᵢ - (mxᵢ + b))²**

Where:
- `m` is the slope
- `b` is the y-intercept
- `(xᵢ, yᵢ)` are data points

### Multiple Linear Regression

For multiple features: **y = β₀ + β₁x₁ + β₂x₂ + ... + βₙxₙ**

## Experiment Ideas

Try modifying the example to:

- **Add noise**: See how noise affects the regression line
- **Non-linear data**: Try polynomial regression
- **Multiple features**: Use multiple input features
- **Different datasets**: Test with your own data
- **Evaluate metrics**: Calculate R², MSE, or other metrics

## Related Examples

- `ml_linreg01` - Basic linear regression
- `ml_linreg02` - Advanced linear regression
- `ml_kmeans_plot` - K-means clustering with plotting
- `plot_scatter_with_regression` - Scatter plot with regression line

## Related Tutorials

- [Regression](../../docs/machine-learning/03-regression.md)
- [Data Preparation](../../docs/machine-learning/01-data-preparation.md)
- [2D Plotting](../../docs/visualization/01-2d-plotting.md)

## Troubleshooting

**Poor fit**: Check if data is actually linear, try adding polynomial features

**Plot doesn't open**: Ensure web browser is installed

**Model errors**: Verify data format and dimensions

**Module errors**: Verify VSL installation with `v list` command

---

Explore more machine learning examples in the [examples directory](../).