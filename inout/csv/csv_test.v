module csv

import os

fn test_parse_csv_basic() {
	content := '1,2,3
4,5,6
7,8,9'

	result := parse_csv(content, CsvReadConfig{})!

	assert result.n_rows == 3
	assert result.n_cols == 3
	assert result.data[0] == [1.0, 2.0, 3.0]
	assert result.data[1] == [4.0, 5.0, 6.0]
	assert result.data[2] == [7.0, 8.0, 9.0]
}

fn test_parse_csv_with_header() {
	content := 'a,b,c
1,2,3
4,5,6'

	result := parse_csv(content, CsvReadConfig{
		skip_header: true
	})!

	assert result.n_rows == 2
	assert result.header == ['a', 'b', 'c']
	assert result.data[0] == [1.0, 2.0, 3.0]
}

fn test_parse_csv_with_comments() {
	content := '# This is a comment
1,2,3
# Another comment
4,5,6'

	result := parse_csv(content, CsvReadConfig{})!

	assert result.n_rows == 2
	assert result.data[0] == [1.0, 2.0, 3.0]
	assert result.data[1] == [4.0, 5.0, 6.0]
}

fn test_parse_csv_skip_rows() {
	content := 'header1,header2
subheader1,subheader2
1,2
3,4'

	result := parse_csv(content, CsvReadConfig{
		skip_rows: 2
	})!

	assert result.n_rows == 2
	assert result.data[0] == [1.0, 2.0]
}

fn test_parse_csv_max_rows() {
	content := '1,2
3,4
5,6
7,8'

	result := parse_csv(content, CsvReadConfig{
		max_rows: 2
	})!

	assert result.n_rows == 2
}

fn test_parse_csv_use_cols() {
	content := '1,2,3,4
5,6,7,8'

	result := parse_csv(content, CsvReadConfig{
		use_cols: [0, 2]
	})!

	assert result.n_cols == 2
	assert result.data[0] == [1.0, 3.0]
	assert result.data[1] == [5.0, 7.0]
}

fn test_parse_csv_different_delimiter() {
	content := '1;2;3
4;5;6'

	result := parse_csv(content, CsvReadConfig{
		delimiter: `;`
	})!

	assert result.data[0] == [1.0, 2.0, 3.0]
}

fn test_csv_get_column() {
	content := '1,2,3
4,5,6
7,8,9'

	result := parse_csv(content, CsvReadConfig{})!
	col := result.get_column(1)!

	assert col == [2.0, 5.0, 8.0]
}

fn test_csv_get_column_by_name() {
	content := 'x,y,z
1,2,3
4,5,6'

	result := parse_csv(content, CsvReadConfig{
		skip_header: true
	})!

	col := result.get_column_by_name('y')!
	assert col == [2.0, 5.0]
}

fn test_csv_to_matrix() {
	content := '1,2
3,4
5,6'

	result := parse_csv(content, CsvReadConfig{})!
	matrix := result.to_matrix()!

	assert matrix.m == 3
	assert matrix.n == 2
	assert matrix.get(0, 0) == 1.0
	assert matrix.get(2, 1) == 6.0
}

fn test_write_and_read_csv() {
	test_file := '/tmp/vsl_test_csv.csv'
	defer {
		os.rm(test_file) or {}
	}

	data := [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]

	write_csv(test_file, data, CsvWriteConfig{
		header: ['a', 'b', 'c']
	})!

	result := read_csv(test_file, CsvReadConfig{
		skip_header: true
	})!

	assert result.n_rows == 2
	assert result.header == ['a', 'b', 'c']
	assert result.data[0][0] == 1.0
}

fn test_parse_csv_floats() {
	content := '1.5,2.7,3.14159
-4.2,0.001,1e-5'

	result := parse_csv(content, CsvReadConfig{})!

	assert result.data[0][0] == 1.5
	assert result.data[0][2] == 3.14159
	assert result.data[1][0] == -4.2
	assert result.data[1][2] == 1e-5
}

fn test_parse_csv_empty_lines() {
	content := '1,2,3

4,5,6

7,8,9'

	result := parse_csv(content, CsvReadConfig{})!

	assert result.n_rows == 3
}
