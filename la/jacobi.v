module la

import math
import vsl.errors

// jacobi performs the Jacobi transformation of a symmetric matrix to find its eigenvectors and
// eigenvalues.
//
// The Jacobi method consists of a sequence of orthogonal similarity transformations. Each
// transformation (a Jacobi rotation) is just a plane rotation designed to annihilate one of the
// off-diagonal matrix elements. Successive transformations undo previously set zeros, but the
// off-diagonal elements nevertheless get smaller and smaller. Accumulating the product of the
// transformations as you go gives the matrix of eigenvectors (Q), while the elements of the final
// diagonal matrix (A) are the eigenvalues.
//
// The Jacobi method is absolutely foolproof for all real symmetric matrices.
//
//         A = Q ⋅ L ⋅ Qᵀ
//
//   Input:
//    A -- matrix to compute eigenvalues (SYMMETRIC and SQUARE)
//   Output:
//    A -- modified
//    Q -- matrix which columns are the eigenvectors
//    v -- vector with the eigenvalues
//
//   NOTE: for matrices of order greater than about 10, say, the algorithm is slower,
//         by a significant constant factor, than the QR method.
//
pub fn jacobi(mut q Matrix[f64], mut v []f64, mut a Matrix[f64]) ! {
	tol := 1e-15
	max_iterations := 20

	n := a.m
	mut b := []f64{len: n}
	mut z := []f64{len: n} // z is the vector of the off-diagonal elements of A

	// Initialize Q to the identity matrix
	for i in 0 .. n {
		for j in 0 .. n {
			q.set(i, j, 0.0)
		}
		q.set(i, i, 1.0)
	}

	// Initialize b and v to the diagonal of A
	for i in 0 .. n {
		b[i] = a.get(i, i)
		v[i] = a.get(i, i)
		z[i] = 0.0
	}

	// Perform iterations
	for _ in 0 .. max_iterations {
		// Sum off-diagonal elements
		mut sum := 0.0
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				sum += math.abs(a.get(i, j))
			}
		}

		// Check for convergence
		if sum < tol {
			break
		}

		// Rotations
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				h := v[j] - v[i]
				if math.abs(a.get(i, j)) < tol {
					continue
				}

				mut t := 0.0
				if math.abs(h) < tol && math.abs(a.get(i, j)) < tol {
					t = 1.0
				} else {
					theta := 0.5 * h / a.get(i, j)
					t = 1.0 / (math.abs(theta) + math.sqrt(1.0 + theta * theta))
					if theta < 0.0 {
						t = -t
					}
				}

				c := 1.0 / math.sqrt(1.0 + t * t)
				s := t * c

				aii := a.get(i, i)
				ajj := a.get(j, j)
				aij := a.get(i, j)
				a.set(i, i, aii - t * aij)
				a.set(j, j, ajj + t * aij)
				v[i] = a.get(i, i)
				v[j] = a.get(j, j)

				a.set(i, j, 0.0)
				a.set(j, i, 0.0)

				for k in 0 .. n {
					if k != i && k != j {
						aik := a.get(i, k)
						ajk := a.get(j, k)
						a.set(i, k, c * aik - s * ajk)
						a.set(j, k, c * ajk + s * aik)
						a.set(k, i, a.get(i, k))
						a.set(k, j, a.get(j, k))
					}
				}

				for k in 0 .. n {
					qik := q.get(k, i)
					qjk := q.get(k, j)
					q.set(k, i, c * qik - s * qjk)
					q.set(k, j, c * qjk + s * qik)
				}
			}
		}
	}

	for i in 0 .. n {
		a.set(i, i, v[i])
		for j in 0 .. n {
			if i != j {
				a.set(i, j, 0.0)
			}
		}
	}

	mut sum := 0.0
	for i in 0 .. n - 1 {
		for j in i + 1 .. n {
			sum += math.abs(a.get(i, j))
		}
	}
	if sum >= tol {
		return errors.error('Jacobi method did not converge', .efailed)
	}
}
