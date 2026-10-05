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
	n := a.m
	if n == 0 || a.n != n {
		return errors.error('Jacobi method requires a non-empty square matrix', .einval)
	}
	if q.m != n || q.n != n || v.len != n {
		return errors.error('Jacobi output dimensions must match the input matrix', .einval)
	}

	max_sweeps := 50

	// Jacobi rotations require a symmetric input. Reject matrices whose
	// asymmetry is larger than the convergence tolerance.
	for i in 0 .. n {
		for j in i + 1 .. n {
			aij := a.get(i, j)
			aji := a.get(j, i)
			symmetry_tol := 1e-14 * math.max(1.0, math.max(math.abs(aij), math.abs(aji)))
			if math.abs(aij - aji) > symmetry_tol {
				return errors.error('Jacobi method requires a symmetric matrix', .einval)
			}
		}
	}

	// Initialize Q to the identity matrix
	for i in 0 .. n {
		for j in 0 .. n {
			q.set(i, j, 0.0)
		}
		q.set(i, i, 1.0)
	}

	// Initialize v to the diagonal of A.
	for i in 0 .. n {
		v[i] = a.get(i, i)
	}

	// Perform cyclic sweeps. Each sweep visits every off-diagonal pair once.
	mut converged := false
	for _ in 0 .. max_sweeps {
		mut all_pairs_converged := true
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				aij := math.abs(a.get(i, j))
				pair_tol := jacobi_pair_tolerance(a.get(i, i), a.get(j, j), aij)
				if aij > pair_tol {
					all_pairs_converged = false
				}
			}
		}
		if all_pairs_converged {
			converged = true
			break
		}

		// Rotations
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				aij := a.get(i, j)
				h := v[j] - v[i]
				pair_tol := jacobi_pair_tolerance(a.get(i, i), a.get(j, j), math.abs(aij))
				if math.abs(aij) <= pair_tol {
					continue
				}

				mut t := 0.0
				theta := 0.5 * h / aij
				t = 1.0 / (math.abs(theta) + math.sqrt(1.0 + theta * theta))
				if theta < 0.0 {
					t = -t
				}

				c := 1.0 / math.sqrt(1.0 + t * t)
				s := t * c

				aii := a.get(i, i)
				ajj := a.get(j, j)
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
				v[i] = a.get(i, i)
				v[j] = a.get(j, j)

				for k in 0 .. n {
					qik := q.get(k, i)
					qjk := q.get(k, j)
					q.set(k, i, c * qik - s * qjk)
					q.set(k, j, c * qjk + s * qik)
				}
			}
		}
	}
	if !converged {
		mut all_pairs_converged := true
		for i in 0 .. n - 1 {
			for j in i + 1 .. n {
				aij := math.abs(a.get(i, j))
				pair_tol := jacobi_pair_tolerance(a.get(i, i), a.get(j, j), aij)
				if aij > pair_tol {
					all_pairs_converged = false
				}
			}
		}
		if !all_pairs_converged {
			return errors.error('Jacobi method did not converge: off-diagonal elements exceed pairwise tolerances',
				.efailed)
		}
	}

	for i in 0 .. n {
		v[i] = a.get(i, i)
		a.set(i, i, v[i])
		for j in 0 .. n {
			if i != j {
				a.set(i, j, 0.0)
			}
		}
	}
}

fn jacobi_pair_tolerance(aii f64, ajj f64, aij f64) f64 {
	return 1e-14 * math.max(1.0, math.max(math.abs(aii), math.max(math.abs(ajj), math.abs(aij))))
}
