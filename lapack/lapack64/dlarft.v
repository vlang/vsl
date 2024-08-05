module lapack64

import math
import vsl.blas

// dlarft forms the triangular factor T of a block reflector H, storing the answer
// in t.
//
//  H = I - V * T * Vᵀ  if store == .column_wise
//  H = I - Vᵀ * T * V  if store == .row_wise
//
// H is defined by a product of the elementary reflectors where
//
//  H = H_0 * H_1 * ... * H_{k-1}  if direct == .forward
//  H = H_{k-1} * ... * H_1 * H_0  if direct == .backward
//
// t is a k×k triangular matrix. t is upper triangular if direct = .forward
// and lower triangular otherwise. This function will panic if t is not of
// sufficient size.
//
// store describes the storage of the elementary reflectors in v. See
// dlarfb for a description of layout.
//
// tau contains the scalar factors of the elementary reflectors H_i.
//
// dlarft is an internal routine. It is exported for testing purposes.
pub fn dlarft(direct Direct, store StoreV, n int, k int, v []f64, ldv int, tau []f64, mut t []f64, ldt int) {
	mv, nv := if store == .row_wise { k, n } else { n, k }
	if direct != .forward && direct != .backward {
		panic(bad_direct)
	}
	if store != .row_wise && store != .column_wise {
		panic(bad_store_v)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if k < 1 {
		panic(k_lt1)
	}
	if ldv < math.max(1, nv) {
		panic(bad_ld_v)
	}
	if tau.len < k {
		panic(short_tau)
	}
	if ldt < math.max(1, k) {
		panic(short_t)
	}

	if n == 0 {
		return
	}

	if v.len < (mv - 1) * ldv + nv {
		panic(short_v)
	}
	if t.len < (k - 1) * ldt + k {
		panic(short_t)
	}

	if direct == .forward {
		mut prevlastv := n - 1
		for i := 0; i < k; i++ {
			prevlastv = math.max(i, prevlastv)
			if tau[i] == 0 {
				for j := 0; j <= i; j++ {
					t[j * ldt + i] = 0
				}
				continue
			}
			mut lastv := 0
			if store == .column_wise {
				// skip trailing zeros
				for lastv = n - 1; lastv >= i + 1; lastv-- {
					if v[lastv * ldv + i] != 0 {
						break
					}
				}
				for j := 0; j < i; j++ {
					t[j * ldt + i] = -tau[i] * v[i * ldv + j]
				}
				j := math.min(lastv, prevlastv)
				blas.dgemv(.trans, j - i, i, -tau[i], v[(i + 1) * ldv..], ldv, v[(i + 1) * ldv + i..],
					ldv, 1.0, mut t[i..], ldt)
			} else {
				for lastv = n - 1; lastv >= i + 1; lastv-- {
					if v[i * ldv + lastv] != 0 {
						break
					}
				}
				for j := 0; j < i; j++ {
					t[j * ldt + i] = -tau[i] * v[j * ldv + i]
				}
				j := math.min(lastv, prevlastv)
				blas.dgemv(.no_trans, i, j - i, -tau[i], v[i + 1..], ldv, v[i * ldv + i + 1..],
					1, 1.0, mut t[i..], ldt)
			}
			blas.dtrmv(.upper, .no_trans, .non_unit, i, t, ldt, mut t[i..], ldt)
			t[i * ldt + i] = tau[i]
			if i > 1 {
				prevlastv = math.max(prevlastv, lastv)
			} else {
				prevlastv = lastv
			}
		}
		return
	}

	mut prevlastv := 0
	for i := k - 1; i >= 0; i-- {
		if tau[i] == 0 {
			for j := i; j < k; j++ {
				t[j * ldt + i] = 0
			}
			continue
		}
		mut lastv := 0
		if i < k - 1 {
			if store == .column_wise {
				for lastv = 0; lastv < i; lastv++ {
					if v[lastv * ldv + i] != 0 {
						break
					}
				}
				for j := i + 1; j < k; j++ {
					t[j * ldt + i] = -tau[i] * v[(n - k + i) * ldv + j]
				}
				j := math.max(lastv, prevlastv)
				blas.dgemv(.trans, n - k + i - j, k - i - 1, -tau[i], v[j * ldv + i + 1..],
					ldv, v[j * ldv + i..], ldv, 1.0, mut t[(i + 1) * ldt + i..], ldt)
			} else {
				for lastv = 0; lastv < i; lastv++ {
					if v[i * ldv + lastv] != 0 {
						break
					}
				}
				for j := i + 1; j < k; j++ {
					t[j * ldt + i] = -tau[i] * v[j * ldv + n - k + i]
				}
				j := math.max(lastv, prevlastv)
				blas.dgemv(.no_trans, k - i - 1, n - k + i - j, -tau[i], v[(i + 1) * ldv + j..],
					ldv, v[i * ldv + j..], 1, 1.0, mut t[(i + 1) * ldt + i..], ldt)
			}
			blas.dtrmv(.lower, .no_trans, .non_unit, k - i - 1, t[(i + 1) * ldt + i + 1..],
				ldt, mut t[(i + 1) * ldt + i..], ldt)
			if i > 0 {
				prevlastv = math.min(prevlastv, lastv)
			} else {
				prevlastv = lastv
			}
		}
		t[i * ldt + i] = tau[i]
	}
}
