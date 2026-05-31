module compute

fn row_to_col_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r + c * rows] = data[r * cols + c]
		}
	}
	return out
}

fn col_to_row_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r * cols + c] = data[r + c * rows]
		}
	}
	return out
}

fn row_to_col_major_f32(data []f32, rows int, cols int) []f32 {
	mut out := []f32{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r + c * rows] = data[r * cols + c]
		}
	}
	return out
}

fn col_to_row_major_f32(data []f32, rows int, cols int) []f32 {
	mut out := []f32{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r * cols + c] = data[r + c * rows]
		}
	}
	return out
}
