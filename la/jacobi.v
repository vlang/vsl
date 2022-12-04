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
pub fn jacobi(mut q Matrix[f64], mut v []f64, mut a Matrix[f64]) ? {
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
	for iteration in 0 .. max_iterations {
		// Sum off-diagonal elements
		mut sum := 0.0
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				sum += math.abs(a.get(i, j))
			}
		}

		// Check for convergence
		if sum < tol {
			return
		}

		// Rotations
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				mut h := v[i] - v[j]
				mut t := 0.0
				if math.abs(h) <= tol {
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
				tau := s / (1.0 + c)
				h = t * a.get(i, j)
				z[i] -= h
				z[j] += h
				v[i] -= h
				v[j] += h
				a.set(i, j, 0.0)
				for k in 0 .. i {
					g := a.get(k, i)
					h = a.get(k, j)
					a.set(k, i, g - s * (h + g * tau))
					a.set(k, j, h + s * (g - h * tau))
				}
				for k in i + 1 .. j {
					g := a.get(i, k)
					h = a.get(k, j)
					a.set(i, k, g - s * (h + g * tau))
					a.set(k, j, h + s * (g - h * tau))
				}
				for k in j + 1 .. n {
					g := a.get(i, k)
					h = a.get(j, k)
					a.set(i, k, g - s * (h + g * tau))
					a.set(j, k, h + s * (g - h * tau))
				}
				for k in 0 .. n {
					g := q.get(k, i)
					h = q.get(k, j)
					q.set(k, i, g - s * (h + g * tau))
					q.set(k, j, h + s * (g - h * tau))
				}
			}
		}

		for i in 0 .. n {
			b[i] += z[i]
			v[i] = b[i]
			z[i] = 0.0
		}
	}

	return errors.error('Jacobi method did not converge', .efailed)
}
