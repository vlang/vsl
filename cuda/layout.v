// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// row_to_col_major converts row-major flat array to column-major.
// For matrix [rows x cols], element (r, c) in row-major flat at index r*cols+c
// becomes element (r, c) in column-major flat at index r + c*rows.
pub fn row_to_col_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r + c * rows] = data[r * cols + c]
		}
	}
	return out
}

// col_to_row_major converts column-major flat array back to row-major.
// For matrix [rows x cols], element (r, c) in column-major flat at index r + c*rows
// becomes element (r, c) in row-major flat at index r*cols+c.
pub fn col_to_row_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r * cols + c] = data[r + c * rows]
		}
	}
	return out
}