# VSL Preprocessing Module

The `vsl.preprocessing` module provides utilities for data preprocessing
commonly used in machine learning pipelines.

## Features

### Scalers
- **StandardScaler**: Standardizes features by removing the mean and scaling
  to unit variance (Z-score normalization)
- **MinMaxScaler**: Transforms features by scaling to a given range (default [0, 1])
- **RobustScaler**: Scales features using statistics robust to outliers (median and IQR)

### Encoders
- **LabelEncoder**: Encodes categorical labels as integers
- **OneHotEncoder**: Encodes categorical features as one-hot numeric arrays
- **OrdinalEncoder**: Encodes categorical features as ordinal integers

### Binning
- **cut**: Bins values into discrete intervals using equal-width binning
- **qcut**: Bins values using quantile-based (equal-frequency) binning
- **Binner**: Fitted binning transformer for consistent bin assignment

## Quick Start

### Standard Scaling (Z-Score Normalization)

```v
import vsl.preprocessing

data := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]

mut scaler := preprocessing.StandardScaler.new()
scaled := scaler.fit_transform(data)!

// Inverse transform to recover original values
recovered := scaler.inverse_transform(scaled)!
```

### Min-Max Scaling

```v
import vsl.preprocessing

data := [[0.0], [50.0], [100.0]]

// Scale to [0, 1] range
mut scaler := preprocessing.MinMaxScaler.new(0.0, 1.0)
scaled := scaler.fit_transform(data)!
// Result: [[0.0], [0.5], [1.0]]

// Or scale to custom range [-1, 1]
mut scaler2 := preprocessing.MinMaxScaler.new(-1.0, 1.0)
scaled2 := scaler2.fit_transform(data)!
// Result: [[-1.0], [0.0], [1.0]]
```

### Robust Scaling

```v
import vsl.preprocessing

// Data with outliers
data := [[1.0], [2.0], [3.0], [4.0], [5.0], [100.0]]

mut scaler := preprocessing.RobustScaler.new()
scaled := scaler.fit_transform(data)!
// Uses median and IQR, so outlier has less effect
```

### Label Encoding

```v
import vsl.preprocessing

labels := ['cat', 'dog', 'bird', 'cat', 'dog']

mut encoder := preprocessing.LabelEncoder.new()
encoded := encoder.fit_transform(labels)!
// Result: [0, 1, 2, 0, 1] (order depends on first occurrence)

// Inverse transform
decoded := encoder.inverse_transform(encoded)!
// Result: ['cat', 'dog', 'bird', 'cat', 'dog']
```

### One-Hot Encoding

```v
import vsl.preprocessing

data := [['red'], ['blue'], ['green'], ['red']]

mut encoder := preprocessing.OneHotEncoder.new(false)
encoded := encoder.fit_transform(data)!
// Result: [[1,0,0], [0,1,0], [0,0,1], [1,0,0]]

// Get feature names
names := encoder.get_feature_names(['color'])!
// Result: ['color_red', 'color_blue', 'color_green']

// Dummy encoding (drop first category)
mut dummy_encoder := preprocessing.OneHotEncoder.new(true)
dummy := dummy_encoder.fit_transform(data)!
// Result: [[0,0], [1,0], [0,1], [0,0]]
```

### Binning

```v
import vsl.preprocessing

values := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

// Equal-width binning
result := preprocessing.cut(values, 2, ['low', 'high'])!

// Quantile binning (equal-frequency)
result2 := preprocessing.qcut(values, 4, ['Q1', 'Q2', 'Q3', 'Q4'])!

// Using Binner for consistent transformation
mut binner := preprocessing.Binner.new(3, .uniform, ['small', 'medium', 'large'])
binner.fit(values)!
binned := binner.transform(values)!
```

## API Reference

### StandardScaler

| Method | Description |
|--------|-------------|
| `new()` | Creates a new StandardScaler |
| `fit(x)` | Computes mean and std from data |
| `transform(x)` | Applies standardization |
| `fit_transform(x)` | Fits and transforms in one step |
| `inverse_transform(x)` | Reverses standardization |

**Attributes after fitting:**
- `mean_`: Mean of each feature
- `std_`: Standard deviation of each feature

### MinMaxScaler

| Method | Description |
|--------|-------------|
| `new(feature_min, feature_max)` | Creates scaler with desired range |
| `fit(x)` | Computes min and max from data |
| `transform(x)` | Applies min-max scaling |
| `fit_transform(x)` | Fits and transforms in one step |
| `inverse_transform(x)` | Reverses scaling |

### RobustScaler

| Method | Description |
|--------|-------------|
| `new()` | Creates a new RobustScaler |
| `fit(x)` | Computes median and IQR from data |
| `transform(x)` | Applies robust scaling |
| `fit_transform(x)` | Fits and transforms in one step |

### LabelEncoder

| Method | Description |
|--------|-------------|
| `new()` | Creates a new LabelEncoder |
| `fit(y)` | Learns unique classes |
| `transform(y)` | Encodes labels to integers |
| `fit_transform(y)` | Fits and transforms in one step |
| `inverse_transform(y)` | Converts integers back to labels |

### OneHotEncoder

| Method | Description |
|--------|-------------|
| `new(drop_first)` | Creates encoder; drop_first for dummy encoding |
| `fit(x)` | Learns categories for each feature |
| `transform(x)` | Applies one-hot encoding |
| `fit_transform(x)` | Fits and transforms in one step |
| `get_feature_names(input_names)` | Returns output feature names |

### Binner

| Method | Description |
|--------|-------------|
| `new(n_bins, strategy, labels)` | Creates binner with specified strategy |
| `fit(values)` | Computes bin edges |
| `transform(values)` | Assigns values to bins |
| `fit_transform(values)` | Fits and transforms in one step |
| `transform_to_indices(values)` | Returns bin indices instead of labels |

**BinningStrategy:**
- `.uniform`: Equal-width bins
- `.quantile`: Equal-frequency bins

## Integration with ML Pipeline

```v
import vsl.preprocessing
import vsl.inout.csv
import vsl.ml

// Load data
csv_data := csv.read_csv('data.csv', csv.CsvReadConfig{ skip_header: true })!

// Scale features
mut scaler := preprocessing.StandardScaler.new()
scaled_data := scaler.fit_transform(csv_data.data)!

// Create ML Data object
mut data := ml.Data.from_raw_xy(scaled_data)!

// Train model
mut model := ml.LinReg.new(mut data, 'my_model')
model.train()

// For new predictions, use the same scaler
new_data := [[1.0, 2.0, 3.0]]
scaled_new := scaler.transform(new_data)!
prediction := model.predict(scaled_new[0])
```

## See Also

- [CSV Module](../inout/csv/README.md)
- [Machine Learning](../ml/README.md)
- [Metrics](../metrics/README.md)
