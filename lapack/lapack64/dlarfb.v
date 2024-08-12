module lapack64

import math
import vsl.blas

pub fn dlarfb(side blas.Side, trans blas.Transpose, direct Direct, store StoreV, m int, n int, k int, v []f64, ldv int, t []f64, ldt int, mut c []f64, ldc int, mut work []f64, ldwork int) {
	if side != .left && side != .right {
		panic(bad_side)
	}
	if trans != .trans && trans != .no_trans {
		panic(bad_trans)
	}
	if direct != .forward && direct != .backward {
		panic(bad_direct)
	}
	if store != .column_wise && store != .row_wise {
		panic(bad_store_v)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if k < 0 {
		panic(k_lt0)
	}
	if store == .column_wise && ldv < math.max(1, k) {
		panic(bad_ld_v)
	}
	if store == .row_wise && ldv < math.max(1, m) {
		panic(bad_ld_v)
	}
	if ldt < math.max(1, k) {
		panic(bad_ld_t)
	}
	if ldc < math.max(1, n) {
		panic(bad_ld_c)
	}
	if ldwork < math.max(1, k) {
		panic(bad_ld_work)
	}

	if m == 0 || n == 0 {
		return
	}

	mut nv := m
	if side == .right {
		nv = n
	}
	if store == .column_wise && v.len < (nv - 1) * ldv + k {
		panic(short_v)
	}
	if store == .row_wise && v.len < (k - 1) * ldv + nv {
		panic(short_v)
	}
	if t.len < (k - 1) * ldt + k {
		panic(short_t)
	}
	if c.len < (m - 1) * ldc + n {
		panic(short_c)
	}
	if work.len < (nv - 1) * ldwork + k {
		panic(short_work)
	}

	transt := if trans == .trans { blas.Transpose.no_trans } else { blas.Transpose.trans }

	if store == .column_wise {
		if direct == .forward {
			if side == .left {
				for j := 0; j < k; j++ {
					blas.dcopy(n, c[j * ldc..], 1, mut work[j * ldwork..], 1)
				}
				blas.dtrmm(.right, .lower, .no_trans, .unit, n, k, 1.0, v, ldv, mut work,
					ldwork)
				if m > k {
					blas.dgemm(.trans, .no_trans, n, k, m - k, 1.0, c[k * ldc..], ldc,
						v[k * ldv..], ldv, 1.0, mut work, ldwork)
				}
				blas.dtrmm(.right, .upper, transt, .non_unit, n, k, 1.0, t, ldt, mut work,
					ldwork)
				if m > k {
					blas.dgemm(.no_trans, .trans, m - k, n, k, -1.0, v[k * ldv..], ldv,
						work, ldwork, 1.0, mut c[k * ldc..], ldc)
				}
				blas.dtrmm(.right, .lower, .trans, .unit, n, k, 1.0, v, ldv, mut work,
					ldwork)
				for i := 0; i < n; i++ {
					for j := 0; j < k; j++ {
						c[j * ldc + i] -= unsafe { work[i * ldwork + j] }
					}
				}
				return
			}
			for j := 0; j < k; j++ {
				blas.dcopy(m, c[j..], ldc, mut work[j * ldwork..], 1)
			}
			blas.dtrmm(.right, .lower, .no_trans, .unit, m, k, 1.0, v, ldv, mut work,
				ldwork)
			if n > k {
				blas.dgemm(.no_trans, .no_trans, m, k, n - k, 1.0, c[k..], ldc, v[k * ldv..],
					ldv, 1.0, mut work, ldwork)
			}
			blas.dtrmm(.right, .upper, trans, .non_unit, m, k, 1.0, t, ldt, mut work,
				ldwork)
			if n > k {
				blas.dgemm(.no_trans, .no_trans, m, n - k, k, -1.0, work, ldwork, v[k * ldv..],
					ldv, 1.0, mut c[k..], ldc)
			}
			blas.dtrmm(.right, .lower, .trans, .unit, m, k, 1.0, v, ldv, mut work, ldwork)
			for i := 0; i < m; i++ {
				for j := 0; j < k; j++ {
					c[i * ldc + j] -= unsafe { work[i * ldwork + j] }
				}
			}
			return
		}
		if side == .left {
			for j := 0; j < k; j++ {
				blas.dcopy(n, c[(m - k + j) * ldc..], 1, mut work[j * ldwork..], 1)
			}
			blas.dtrmm(.right, .upper, .no_trans, .unit, n, k, 1.0, v[(m - k) * ldv..],
				ldv, mut work, ldwork)
			if m > k {
				blas.dgemm(.trans, .no_trans, n, k, m - k, 1.0, c, ldc, v, ldv, 1.0, mut
					work, ldwork)
			}
			blas.dtrmm(.right, .lower, transt, .non_unit, n, k, 1.0, t, ldt, mut work,
				ldwork)
			if m > k {
				blas.dgemm(.no_trans, .trans, m - k, n, k, -1.0, v, ldv, work, ldwork,
					1.0, mut c, ldc)
			}
			blas.dtrmm(.right, .upper, .trans, .unit, n, k, 1.0, v[(m - k) * ldv..], ldv, mut
				work, ldwork)
			for i := 0; i < n; i++ {
				for j := 0; j < k; j++ {
					c[(m - k + j) * ldc + i] -= unsafe { work[i * ldwork + j] }
				}
			}
			return
		}
		for j := 0; j < k; j++ {
			blas.dcopy(m, c[(n - k + j)..], ldc, mut work[j * ldwork..], 1)
		}
		blas.dtrmm(.right, .upper, .no_trans, .unit, m, k, 1.0, v[(n - k) * ldv..], ldv, mut
			work, ldwork)
		if n > k {
			blas.dgemm(.no_trans, .no_trans, m, k, n - k, 1.0, c, ldc, v, ldv, 1.0, mut
				work, ldwork)
		}
		blas.dtrmm(.right, .lower, trans, .non_unit, m, k, 1.0, t, ldt, mut work, ldwork)
		if n > k {
			blas.dgemm(.no_trans, .trans, m, n - k, k, -1.0, work, ldwork, v, ldv, 1.0, mut
				c, ldc)
		}
		blas.dtrmm(.right, .upper, .trans, .unit, m, k, 1.0, v[(n - k) * ldv..], ldv, mut
			work, ldwork)
		for i := 0; i < m; i++ {
			for j := 0; j < k; j++ {
				c[i * ldc + (n - k + j)] -= unsafe { work[i * ldwork + j] }
			}
		}
		return
	}
	if direct == .forward {
		if side == .left {
			for j := 0; j < k; j++ {
				blas.dcopy(n, c[j * ldc..], 1, mut work[j * ldwork..], 1)
			}
			blas.dtrmm(.right, .upper, .trans, .unit, n, k, 1.0, v, ldv, mut work, ldwork)
			if m > k {
				blas.dgemm(.trans, .trans, n, k, m - k, 1.0, c[k * ldc..], ldc, v[k..],
					ldv, 1.0, mut work, ldwork)
			}
			blas.dtrmm(.right, .upper, transt, .non_unit, n, k, 1.0, t, ldt, mut work,
				ldwork)
			if m > k {
				blas.dgemm(.trans, .trans, m - k, n, k, -1.0, v[k..], ldv, work, ldwork,
					1.0, mut c[k * ldc..], ldc)
			}
			blas.dtrmm(.right, .upper, .no_trans, .unit, n, k, 1.0, v, ldv, mut work,
				ldwork)
			for i := 0; i < n; i++ {
				for j := 0; j < k; j++ {
					c[j * ldc + i] -= unsafe { work[i * ldwork + j] }
				}
			}
			return
		}
		for j := 0; j < k; j++ {
			blas.dcopy(m, c[j..], ldc, mut work[j * ldwork..], 1)
		}
		blas.dtrmm(.right, .upper, .trans, .unit, m, k, 1.0, v, ldv, mut work, ldwork)
		if n > k {
			blas.dgemm(.no_trans, .trans, m, k, n - k, 1.0, c[k..], ldc, v[k..], ldv,
				1.0, mut work, ldwork)
		}
		blas.dtrmm(.right, .upper, trans, .non_unit, m, k, 1.0, t, ldt, mut work, ldwork)
		if n > k {
			blas.dgemm(.no_trans, .trans, m, n - k, k, -1.0, work, ldwork, v[k..], ldv,
				1.0, mut c[k..], ldc)
		}
		blas.dtrmm(.right, .upper, .no_trans, .unit, m, k, 1.0, v, ldv, mut work, ldwork)
		for i := 0; i < m; i++ {
			for j := 0; j < k; j++ {
				c[i * ldc + j] -= unsafe { work[i * ldwork + j] }
			}
		}
		return
	}
	if side == .left {
		for j := 0; j < k; j++ {
			blas.dcopy(n, c[(m - k + j) * ldc..], 1, mut work[j * ldwork..], 1)
		}
		blas.dtrmm(.right, .lower, .no_trans, .unit, n, k, 1.0, v[(m - k)..], ldv, mut
			work, ldwork)
		if m > k {
			blas.dgemm(.trans, .no_trans, n, k, m - k, 1.0, c, ldc, v, ldv, 1.0, mut work,
				ldwork)
		}
		blas.dtrmm(.right, .lower, transt, .non_unit, n, k, 1.0, t, ldt, mut work, ldwork)
		if m > k {
			blas.dgemm(.no_trans, .trans, m - k, n, k, -1.0, v, ldv, work, ldwork, 1.0, mut
				c, ldc)
		}
		blas.dtrmm(.right, .lower, .trans, .unit, n, k, 1.0, v[(m - k)..], ldv, mut work,
			ldwork)
		for i := 0; i < n; i++ {
			for j := 0; j < k; j++ {
				c[(m - k + j) * ldc + i] -= unsafe { work[i * ldwork + j] }
			}
		}
		return
	}
	for j := 0; j < k; j++ {
		blas.dcopy(m, c[(n - k + j)..], ldc, mut work[j * ldwork..], 1)
	}
	blas.dtrmm(.right, .lower, .no_trans, .unit, m, k, 1.0, v[(n - k)..], ldv, mut work,
		ldwork)
	if n > k {
		blas.dgemm(.no_trans, .trans, m, k, n - k, 1.0, c, ldc, v, ldv, 1.0, mut work,
			ldwork)
	}
	blas.dtrmm(.right, .lower, trans, .non_unit, m, k, 1.0, t, ldt, mut work, ldwork)
	if n > k {
		blas.dgemm(.no_trans, .no_trans, m, n - k, k, -1.0, work, ldwork, v, ldv, 1.0, mut
			c, ldc)
	}
	blas.dtrmm(.right, .lower, .trans, .unit, m, k, 1.0, v[(n - k)..], ldv, mut work,
		ldwork)
	for i := 0; i < m; i++ {
		for j := 0; j < k; j++ {
			c[i * ldc + (n - k + j)] -= unsafe { work[i * ldwork + j] }
		}
	}
}
