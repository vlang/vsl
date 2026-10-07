module la

import vsl.errors
import math

// lstsq solves the linear least-squares problem: minimise ||A·x − B||₂ for each column of B.
//
// Uses a full SVD-based pseudo-inverse. By default singular values at or below
// `max(m, n) * machine_epsilon * largest_singular_value` are treated as zero.
//
// Returns `(x, residuals, rank, singular_values)` where:
//   - `x`               — solution matrix (n × nrhs)
//   - `residuals`       — squared residual per RHS column when m > n and A has full column rank; otherwise empty
//   - `rank`            — effective numerical rank under the selected cutoff
//   - `singular_values` — descending singular values of A
//
// Panics if `b.m != a.m`.
//
// Example:
// ```v
// // Fit y = c0 + c1*x to three points
// a := la.matrix_raw(3, 2, [1.0, 0.0,  1.0, 1.0,  1.0, 2.0])
// b := la.matrix_raw(3, 1, [1.0, 3.0, 5.0])
// x, _, _, _ := la.lstsq(a, b)
// // x ≈ [[1.0], [2.0]]  →  y = 1 + 2·x
// ```
pub fn lstsq(a &Matrix[f64], b &Matrix[f64]) ([][]f64, []f64, int, []f64) {
	return lstsq_with_rcond(a, b, -1)
}

// lstsq_with_rcond solves a linear least-squares problem using the SVD.
// A non-negative rcond is a relative cutoff against the largest singular
// value. A negative rcond selects the NumPy-style machine-precision default.
pub fn lstsq_with_rcond(a &Matrix[f64], b &Matrix[f64], rcond f64) ([][]f64, []f64, int, []f64) {
	if b.m != a.m {
		errors.vsl_panic('lstsq: A and B must have the same number of rows', .efailed)
	}
	if math.is_nan(rcond) || math.is_inf(rcond, 0) {
		errors.vsl_panic('lstsq: rcond must be finite', .efailed)
	}
	m := a.m
	n := a.n
	nrhs := b.n
	if m == 0 || n == 0 {
		return [][]f64{len: n, init: []f64{len: nrhs}}, []f64{}, 0, []f64{}
	}
	$if vsl_lapack_lapacke ? {
		return lstsq_lapack(a, b, rcond)
	} $else {
		return lstsq_jacobi(a, b, rcond)
	}
}

fn lstsq_lapack(a &Matrix[f64], b &Matrix[f64], rcond f64) ([][]f64, []f64, int, []f64) {
	m := a.m
	n := a.n
	nrhs := b.n
	// SVD: A = U * S * Vt
	mut a_svd := a.clone()
	mut s := []f64{len: int_min(m, n)}
	mut u_mat := Matrix.new[f64](m, m)
	mut vt_mat := Matrix.new[f64](n, n)
	matrix_svd(mut s, mut u_mat, mut vt_mat, mut a_svd, false)

	// x = V * Σ⁻¹ * U^T * b (pseudo-inverse via SVD).
	cutoff := if rcond < 0 { f64(int_max(m, n)) * 2.220446049250313e-16 } else { rcond }
	tol := cutoff * s[0]
	mut effective_rank := 0
	for singular_value in s {
		if singular_value > tol {
			effective_rank++
		}
	}
	mut x := [][]f64{len: n, init: []f64{len: nrhs}}
	for j := 0; j < nrhs; j++ {
		for i := 0; i < n; i++ {
			mut sum := 0.0
			for k := 0; k < int_min(m, n); k++ {
				if s[k] > tol {
					sum += vt_mat.get(k, i) * u_mat.get(j, k) / s[k]
				}
			}
			x[i][j] = sum
		}
	}

	// NumPy exposes squared residuals only for overdetermined, full-rank systems.
	mut residuals := if m > n && effective_rank == n { []f64{len: nrhs} } else { []f64{} }
	if residuals.len > 0 {
		for j := 0; j < nrhs; j++ {
			mut r := 0.0
			for i := 0; i < m; i++ {
				mut ax_i := 0.0
				for k := 0; k < n; k++ {
					ax_i += a.get(i, k) * x[k][j]
				}
				dx := ax_i - b.get(i, j)
				r += dx * dx
			}
			residuals[j] = r
		}
	}

	return x, residuals, effective_rank, s
}

fn lstsq_jacobi(a &Matrix[f64], b &Matrix[f64], rcond f64) ([][]f64, []f64, int, []f64) {
	m := a.m
	n := a.n
	nrhs := b.n
	mut scale := 0.0
	for value in a.data {
		scale = math.max(scale, math.abs(value))
	}
	if scale == 0 {
		return [][]f64{len: n, init: []f64{len: nrhs}}, []f64{}, 0, []f64{len: int_min(m, n)}
	}
	// Orthogonalize the smaller dimension directly to avoid squaring the
	// condition number through normal equations.
	transposed := m < n
	rows := if transposed { n } else { m }
	columns := if transposed { m } else { n }
	mut work := Matrix.new[f64](rows, columns)
	for i in 0 .. rows {
		for j in 0 .. columns {
			work.set(i, j, if transposed { a.get(j, i) / scale } else { a.get(i, j) / scale })
		}
	}
	mut right := Matrix.new[f64](columns, columns)
	for i in 0 .. columns {
		right.set(i, i, 1.0)
	}
	if !jacobi_orthogonalize_columns(mut work, mut right) {
		errors.vsl_panic('lstsq: Jacobi SVD did not converge', .efailed)
	}
	mut singular_scaled := []f64{len: columns}
	for column in 0 .. columns {
		mut squared_norm := 0.0
		for row in 0 .. rows {
			value := work.get(row, column)
			squared_norm += value * value
		}
		singular_scaled[column] = math.sqrt(squared_norm)
	}
	for i in 0 .. columns {
		for j in i + 1 .. columns {
			if singular_scaled[j] > singular_scaled[i] {
				singular_scaled[i], singular_scaled[j] = singular_scaled[j], singular_scaled[i]
				for row in 0 .. rows {
					work.data[row * columns + i], work.data[row * columns + j] = work.data[row * columns + j], work.data[row * columns + i]
				}
				for row in 0 .. columns {
					right.data[row * columns + i], right.data[row * columns + j] = right.data[row * columns + j], right.data[row * columns + i]
				}
			}
		}
	}
	mut singular_values := []f64{len: columns}
	for i, value in singular_scaled {
		singular_values[i] = value * scale
	}
	cutoff := if rcond < 0 { f64(int_max(m, n)) * 2.220446049250313e-16 } else { rcond }
	tol := cutoff * singular_values[0]
	mut effective_rank := 0
	for value in singular_values {
		if value > tol {
			effective_rank++
		}
	}
	mut x := [][]f64{len: n, init: []f64{len: nrhs}}
	for component in 0 .. effective_rank {
		sigma := singular_scaled[component]
		if transposed {
			for row in 0 .. n {
				left_value := work.get(row, component)
				for rhs in 0 .. nrhs {
					mut projection := 0.0
					for i in 0 .. m {
						projection += right.get(i, component) * b.get(i, rhs)
					}
					x[row][rhs] += left_value * projection / (sigma * sigma * scale)
				}
			}
		} else {
			for rhs in 0 .. nrhs {
				mut projection := 0.0
				for row in 0 .. m {
					projection += work.get(row, component) * b.get(row, rhs)
				}
				coefficient := projection / (sigma * sigma * scale)
				for row in 0 .. n {
					x[row][rhs] += right.get(row, component) * coefficient
				}
			}
		}
	}
	mut residuals := if m > n && effective_rank == n { []f64{len: nrhs} } else { []f64{} }
	if residuals.len > 0 {
		for rhs in 0 .. nrhs {
			mut squared_residual := 0.0
			for row in 0 .. m {
				mut difference := -b.get(row, rhs)
				for column in 0 .. n {
					difference += a.get(row, column) * x[column][rhs]
				}
				squared_residual += difference * difference
			}
			residuals[rhs] = squared_residual
		}
	}
	return x, residuals, effective_rank, singular_values
}

fn jacobi_orthogonalize_columns(mut work Matrix[f64], mut right Matrix[f64]) bool {
	rows := work.m
	columns := work.n
	max_sweeps := 100
	for _ in 0 .. max_sweeps {
		mut changed := false
		for p in 0 .. columns - 1 {
			for q in p + 1 .. columns {
				mut alpha := 0.0
				mut beta := 0.0
				mut gamma := 0.0
				for row in 0 .. rows {
					left := work.get(row, p)
					right_value := work.get(row, q)
					alpha += left * left
					beta += right_value * right_value
					gamma += left * right_value
				}
				if gamma == 0 || math.abs(gamma) <= 2.220446049250313e-16 * f64(int_max(rows,
					columns)) * math.sqrt(alpha * beta) {
					continue
				}
				zeta := (beta - alpha) / (2.0 * gamma)
				t := if zeta < 0 {
					-1.0 / (math.abs(zeta) + math.sqrt(1.0 + zeta * zeta))
				} else {
					1.0 / (math.abs(zeta) + math.sqrt(1.0 + zeta * zeta))
				}
				cosine := 1.0 / math.sqrt(1.0 + t * t)
				sine := t * cosine
				for row in 0 .. rows {
					left := work.get(row, p)
					right_value := work.get(row, q)
					work.set(row, p, cosine * left - sine * right_value)
					work.set(row, q, sine * left + cosine * right_value)
				}
				for row in 0 .. columns {
					left := right.get(row, p)
					right_value := right.get(row, q)
					right.set(row, p, cosine * left - sine * right_value)
					right.set(row, q, sine * left + cosine * right_value)
				}
				changed = true
			}
		}
		if !changed {
			return true
		}
	}
	return false
}
