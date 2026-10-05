module la

import vsl.float.float64
import math

fn test_jacobi01() {
	mut a := Matrix.deep2([
		[2.0, 0, 0],
		[0.0, 2, 0],
		[0.0, 0, 2],
	])

	mut q := Matrix.new[f64](3, 3)
	mut v := []f64{len: 3}

	mut expected_q := Matrix.deep2([
		[1.0, 0, 0],
		[0.0, 1, 0],
		[0.0, 0, 1],
	])

	mut expected_v := [2.0, 2.0, 2.0]
	mut expected_a := Matrix.deep2([
		[2.0, 0.0, 0.0],
		[0.0, 2.0, 0.0],
		[0.0, 0.0, 2.0],
	])

	jacobi(mut q, mut v, mut a)!

	assert float64.arrays_tolerance(q.data, expected_q.data, 1e-14)
	assert float64.arrays_tolerance(v, expected_v, 1e-14)
	assert float64.arrays_tolerance(a.data, expected_a.data, 1e-14)
}

fn test_jacobi_3x3_symmetric() {
	mut a := Matrix.deep2([
		[4.0, 1.0, 1.0],
		[1.0, 3.0, 0.0],
		[1.0, 0.0, 2.0],
	])

	mut q := Matrix.new[f64](3, 3)
	mut v := []f64{len: 3}

	mut expected_q := Matrix.deep2([
		[0.8440296287459851, -0.29312841385727223, -0.4490987851112868],
		[0.4490987851112867, 0.8440296287459852, 0.29312841385727234],
		[0.29312841385727223, -0.44909878511128676, 0.8440296287459852],
	])

	mut expected_v := [4.879385241571816, 2.652703644666139, 1.4679111137620442]
	mut expected_a := Matrix.deep2([
		[4.879385241571816, 0.0, 0.0],
		[0.0, 2.652703644666139, 0.0],
		[0.0, 0.0, 1.4679111137620442],
	])

	jacobi(mut q, mut v, mut a)!

	assert float64.arrays_tolerance(v, expected_v, 1e-14)
	assert float64.arrays_tolerance(q.data, expected_q.data, 1e-14)
	assert float64.arrays_tolerance(a.data, expected_a.data, 1e-14)
}

fn test_jacobi_harmonic_oscillator_reconstructs_original_matrix() {
	n := 20
	dx := 12.0 / f64(n - 1)
	mut original := Matrix.new[f64](n, n)
	mut x := -6.0
	for i in 0 .. n {
		original.set(i, i, 1.0 / (dx * dx) + x * x / 2.0)
		if i > 0 {
			original.set(i, i - 1, -1.0 / (2.0 * dx * dx))
			original.set(i - 1, i, -1.0 / (2.0 * dx * dx))
		}
		x += dx
	}
	mut a := original.clone()
	mut q := Matrix.new[f64](n, n)
	mut values := []f64{len: n}

	jacobi(mut q, mut values, mut a)!

	mut eigenvalue_sum := 0.0
	for value in values {
		eigenvalue_sum += value
	}
	mut trace := 0.0
	for i in 0 .. n {
		trace += original.get(i, i)
	}
	assert math.abs(eigenvalue_sum - trace) < 1e-10

	// A Q = Q D verifies eigenvalues and eigenvectors together, avoiding a
	// test that can pass with plausible-looking eigenvalues and wrong vectors.
	for row in 0 .. n {
		for col in 0 .. n {
			mut aq := 0.0
			for k in 0 .. n {
				aq += original.get(row, k) * q.get(k, col)
			}
			qd := q.get(row, col) * values[col]
			assert math.abs(aq - qd) < 1e-10
		}
	}
}

fn test_jacobi_rejects_non_symmetric_matrix() {
	mut a := Matrix.deep2([
		[1.0, 2.0],
		[0.0, 3.0],
	])
	mut q := Matrix.new[f64](2, 2)
	mut values := []f64{len: 2}
	jacobi(mut q, mut values, mut a) or {
		assert err.msg().contains('symmetric')
		return
	}
	assert false, 'expected a non-symmetric matrix to be rejected'
}

fn test_jacobi_rejects_output_dimension_mismatch() {
	mut a := Matrix.deep2([
		[1.0, 0.0],
		[0.0, 2.0],
	])
	mut q := Matrix.new[f64](2, 2)
	mut values := []f64{len: 1}
	jacobi(mut q, mut values, mut a) or {
		assert err.msg().contains('dimensions')
		return
	}
	assert false, 'expected mismatched output dimensions to be rejected'
}
