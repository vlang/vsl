module csv

import os
import vsl.la
import vsl.errors

// CsvReadConfig holds configuration for reading CSV files
pub struct CsvReadConfig {
pub:
	delimiter   u8 = `,` // field delimiter
	skip_header bool  // skip the first row
	skip_rows   int   // number of rows to skip at the beginning
	use_cols    []int // indices of columns to use (empty = all)
	max_rows    int = -1  // maximum number of rows to read (-1 = all)
	comment     u8  = `#` // comment character (lines starting with this are skipped)
}

// CsvWriteConfig holds configuration for writing CSV files
pub struct CsvWriteConfig {
pub:
	delimiter    u8 = `,` // field delimiter
	header       []string // optional header row
	float_format string = '%.6g' // format for floating point numbers
}

// CsvData holds the result of reading a CSV file
pub struct CsvData {
pub:
	data        [][]f64    // the numeric data
	header      []string   // header row (if present)
	n_rows      int        // number of data rows
	n_cols      int        // number of columns
	raw_strings [][]string // original string data (for non-numeric columns)
}

// read_csv reads a CSV file and returns numeric data as a 2D array
// Non-numeric values are converted to NaN
pub fn read_csv(path string, config CsvReadConfig) !CsvData {
	if !os.exists(path) {
		return errors.error('file not found: ${path}', .efailed)
	}

	content := os.read_file(path) or {
		return errors.error('failed to read file: ${path}', .efailed)
	}

	return parse_csv(content, config)
}

// parse_csv parses CSV content from a string
pub fn parse_csv(content string, config CsvReadConfig) !CsvData {
	lines := content.split_into_lines()
	if lines.len == 0 {
		return errors.error('empty CSV content', .efailed)
	}

	mut data := [][]f64{}
	mut raw_strings := [][]string{}
	mut header := []string{}
	mut row_count := 0
	mut skip_count := config.skip_rows
	mut header_parsed := false

	delimiter := config.delimiter.ascii_str()

	for line in lines {
		// Skip empty lines
		trimmed := line.trim_space()
		if trimmed.len == 0 {
			continue
		}

		// Skip comment lines
		if trimmed[0] == config.comment {
			continue
		}

		// Skip specified number of rows
		if skip_count > 0 {
			skip_count--
			continue
		}

		// Handle header
		if config.skip_header && !header_parsed {
			header = trimmed.split(delimiter).map(it.trim_space())
			header_parsed = true
			continue
		}

		// Check max rows
		if config.max_rows > 0 && row_count >= config.max_rows {
			break
		}

		// Parse row
		fields := trimmed.split(delimiter)
		mut row := []f64{}
		mut raw_row := []string{}

		for j, field in fields {
			// Check if column should be used
			if config.use_cols.len > 0 && j !in config.use_cols {
				continue
			}

			clean_field := field.trim_space().trim('"\'')
			raw_row << clean_field

			// Try to parse as float
			val := clean_field.f64()
			row << val
		}

		if row.len > 0 {
			data << row
			raw_strings << raw_row
			row_count++
		}
	}

	n_cols := if data.len > 0 { data[0].len } else { 0 }

	return CsvData{
		data:        data
		header:      header
		n_rows:      data.len
		n_cols:      n_cols
		raw_strings: raw_strings
	}
}

// read_csv_to_matrix reads a CSV file and returns the data as a Matrix
pub fn read_csv_to_matrix(path string, config CsvReadConfig) !&la.Matrix[f64] {
	csv_data := read_csv(path, config)!

	if csv_data.n_rows == 0 || csv_data.n_cols == 0 {
		return errors.error('empty CSV data', .efailed)
	}

	mut matrix := la.Matrix.new[f64](csv_data.n_rows, csv_data.n_cols)
	for i in 0 .. csv_data.n_rows {
		for j in 0 .. csv_data.n_cols {
			matrix.set(i, j, csv_data.data[i][j])
		}
	}

	return matrix
}

// write_csv writes a 2D array to a CSV file
pub fn write_csv(path string, data [][]f64, config CsvWriteConfig) ! {
	mut lines := []string{}
	delimiter := config.delimiter.ascii_str()

	// Write header if present
	if config.header.len > 0 {
		lines << config.header.join(delimiter)
	}

	// Write data rows
	for row in data {
		mut fields := []string{}
		for val in row {
			fields << format_float(val, config.float_format)
		}
		lines << fields.join(delimiter)
	}

	os.write_file(path, lines.join('\n')) or {
		return errors.error('failed to write file: ${path}', .efailed)
	}
}

// write_matrix_csv writes a Matrix to a CSV file
pub fn write_matrix_csv(path string, matrix &la.Matrix[f64], config CsvWriteConfig) ! {
	mut data := [][]f64{}
	for i in 0 .. matrix.m {
		data << matrix.get_row(i)
	}
	write_csv(path, data, config)!
}

// format_float formats a float according to the format string
fn format_float(val f64, format string) string {
	// Simple implementation - use default formatting
	if val != val { // NaN check
		return 'NaN'
	}
	return '${val}'
}

// to_matrix converts CsvData to a Matrix
pub fn (c &CsvData) to_matrix() !&la.Matrix[f64] {
	if c.n_rows == 0 || c.n_cols == 0 {
		return errors.error('empty CSV data', .efailed)
	}

	mut matrix := la.Matrix.new[f64](c.n_rows, c.n_cols)
	for i in 0 .. c.n_rows {
		for j in 0 .. c.n_cols {
			matrix.set(i, j, c.data[i][j])
		}
	}

	return matrix
}

// get_column returns a specific column as an array
pub fn (c &CsvData) get_column(idx int) ![]f64 {
	if idx < 0 || idx >= c.n_cols {
		return errors.error('column index out of bounds', .einval)
	}

	mut col := []f64{len: c.n_rows}
	for i in 0 .. c.n_rows {
		col[i] = c.data[i][idx]
	}
	return col
}

// get_column_by_name returns a column by its header name
pub fn (c &CsvData) get_column_by_name(name string) ![]f64 {
	for i, h in c.header {
		if h == name {
			return c.get_column(i)
		}
	}
	return errors.error('column not found: ${name}', .einval)
}
