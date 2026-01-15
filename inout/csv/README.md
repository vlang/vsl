# VSL CSV Module

The `vsl.inout.csv` module provides utilities for reading and writing CSV files
commonly used in scientific computing and machine learning workflows.

## Features

- **CSV Reading**: Parse CSV files into numeric arrays or matrices
- **CSV Writing**: Export data to CSV format
- **Flexible Configuration**: Handle headers, delimiters, comments, and column selection
- **Matrix Integration**: Direct conversion to `vsl.la.Matrix` types

## Quick Start

### Reading CSV Files

```v
import vsl.inout.csv

// Basic CSV reading
csv_data := csv.read_csv('data.csv', csv.CsvReadConfig{})!
println('Rows: ${csv_data.n_rows}, Cols: ${csv_data.n_cols}')

// Access the data
for row in csv_data.data {
	println(row)
}
```

### Reading with Header

```v
import vsl.inout.csv

csv_data := csv.read_csv('data.csv', csv.CsvReadConfig{
	skip_header: true
})!

println('Columns: ${csv_data.header}')

// Get column by name
ages := csv_data.get_column_by_name('age')!
```

### Reading Specific Columns

```v
import vsl.inout.csv

// Only read columns 0, 2, and 4
csv_data := csv.read_csv('data.csv', csv.CsvReadConfig{
	use_cols: [0, 2, 4]
})!
```

### Converting to Matrix

```v
import vsl.inout.csv

// Read directly as a Matrix
matrix := csv.read_csv_to_matrix('data.csv', csv.CsvReadConfig{
	skip_header: true
})!

println('Matrix dimensions: ${matrix.m} x ${matrix.n}')
```

### Writing CSV Files

```v
import vsl.inout.csv

data := [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]

csv.write_csv('output.csv', data, csv.CsvWriteConfig{
	header: ['x', 'y', 'z']
})!
```

## Configuration Options

### CsvReadConfig

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `delimiter` | `u8` | `,` | Field delimiter character |
| `skip_header` | `bool` | `false` | Skip first row and store as header |
| `skip_rows` | `int` | `0` | Number of rows to skip at beginning |
| `use_cols` | `[]int` | `[]` | Column indices to use (empty = all) |
| `max_rows` | `int` | `-1` | Maximum rows to read (-1 = all) |
| `comment` | `u8` | `#` | Comment character (lines starting with this are skipped) |

### CsvWriteConfig

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `delimiter` | `u8` | `,` | Field delimiter character |
| `header` | `[]string` | `[]` | Optional header row |
| `float_format` | `string` | `%.6g` | Format string for floats |

## CsvData Methods

- `to_matrix()` - Convert to `la.Matrix[f64]`
- `get_column(idx)` - Get column by index
- `get_column_by_name(name)` - Get column by header name

## Examples

### Handling Different Delimiters

```v
import vsl.inout.csv

// Tab-separated values
csv_data := csv.read_csv('data.tsv', csv.CsvReadConfig{
	delimiter: `\t`
})!

// Semicolon-separated
csv_data2 := csv.read_csv('data.csv', csv.CsvReadConfig{
	delimiter: `;`
})!
```

### Parsing CSV String

```v
import vsl.inout.csv

content := 'x,y
1,2
3,4
5,6'

csv_data := csv.parse_csv(content, csv.CsvReadConfig{
	skip_header: true
})!
```

## Integration with ML Module

```v
import vsl.inout.csv
import vsl.ml

// Read data for machine learning
csv_data := csv.read_csv('dataset.csv', csv.CsvReadConfig{
	skip_header: true
})!

// Create ML Data object
matrix := csv_data.to_matrix()!
mut ml_data := ml.Data.from_raw_xy(csv_data.data)!

// Split into train/test
train_data, test_data := ml_data.split(0.8)!
```

## See Also

- [HDF5 Module](../h5/README.md)
- [Data Preparation](../../docs/machine-learning/01-data-preparation.md)
- [Linear Algebra](../../la/README.md)
- [Machine Learning](../../ml/README.md)
