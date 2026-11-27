module la

import math

const strassen_test_tol = 1e-9

fn strassen_test_matrix(n int, seed int) &Matrix[f64] {
	mut m := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			m.set(i, j, f64((i * (seed + 1) + j * (seed * 2 + 3)) % 97) / 100.0)
		}
	}
	return m
}

fn test_strassen_large_product_matches_naive() {
	n := 128
	a := strassen_test_matrix(n, 1)
	b := strassen_test_matrix(n, 2)
	mut c := a * b

	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, sum)
		}
	}

	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}

fn test_strassen_fallback_cancellation_case() {
	n := 128
	mut a := Matrix.new[f64](n, n)
	mut b := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			a.set(i, j, 0.0)
			b.set(i, j, 0.0)
		}
	}
	a.set(0, 0, 1.0)
	a.set(64, 64, 1e16)
	b.set(0, 0, 1.0)
	b.set(64, 64, 1.0)

	mut c := a * b
	assert c.get(0, 0) == 1.0
	assert c.get(64, 64) == 1e16
}

fn test_strassen_fallback_non_finite_inputs() {
	n := 128
	mut a := strassen_test_matrix(n, 3)
	mut b := strassen_test_matrix(n, 4)
	a.set(0, 0, math.inf(1))
	mut c := a * b
	// The result must contain the propagated non-finite value rather than
	// crashing or silently dropping it.
	assert c.get(0, 0) != c.get(0, 0) || c.get(0, 0) == math.inf(1) || c.get(0, 0) == math.inf(-1)
}

fn test_strassen_alpha_one_required() {
	a := Matrix.deep2([[1.0, 2.0], [3.0, 4.0]])
	b := Matrix.deep2([[5.0, 6.0], [7.0, 8.0]])
	mut c := Matrix.new[f64](2, 2)
	matrix_matrix_mul(mut c, 2.0, a, b)
	assert c.get(0, 0) == 38.0
	assert c.get(0, 1) == 44.0
	assert c.get(1, 0) == 86.0
	assert c.get(1, 1) == 100.0
}

// The alpha == 1.0 gate must hold at Strassen-eligible sizes too: a broken
// gate would feed alpha != 1 into strassen_flat, which scales nothing, and
// the result would come out unscaled relative to alpha*a*b.
fn test_strassen_skips_path_when_alpha_not_one() {
	n := 128
	a := strassen_test_matrix(n, 13)
	b := strassen_test_matrix(n, 14)
	mut c := Matrix.new[f64](n, n)
	matrix_matrix_mul(mut c, 2.0, a, b)

	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, 2.0 * sum)
		}
	}
	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}

fn test_strassen_direct_128_matches_reference() {
	n := 128
	a := strassen_test_matrix(n, 7)
	b := strassen_test_matrix(n, 8)
	mut c := Matrix.new[f64](n, n)
	strassen_matrix_mul(mut c, a, b)

	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, sum)
		}
	}
	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}

fn test_strassen_direct_256_matches_reference() {
	n := 256
	a := strassen_test_matrix(n, 9)
	b := strassen_test_matrix(n, 10)
	mut c := Matrix.new[f64](n, n)
	strassen_matrix_mul(mut c, a, b)

	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, sum)
		}
	}
	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}

fn test_strassen_direct_130_matches_reference() {
	n := 130
	a := strassen_test_matrix(n, 11)
	b := strassen_test_matrix(n, 12)
	mut c := Matrix.new[f64](n, n)
	strassen_matrix_mul(mut c, a, b)

	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, sum)
		}
	}
	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}

fn test_strassen_odd_dimension_uses_blas() {
	n := 129
	a := strassen_test_matrix(n, 5)
	b := strassen_test_matrix(n, 6)
	mut c := a * b
	mut expected := Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. n {
				sum += a.get(i, k) * b.get(k, j)
			}
			expected.set(i, j, sum)
		}
	}
	for i in 0 .. n * n {
		scale := math.max(1.0, math.abs(expected.data[i]))
		assert math.abs(c.data[i] - expected.data[i]) <= strassen_test_tol * scale
	}
}
