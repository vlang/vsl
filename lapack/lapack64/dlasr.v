module lapack64

import math
import vsl.blas

// Dlasr applies a sequence of plane rotations to the m×n matrix A. This series
// of plane rotations is implicitly represented by a matrix P. P is multiplied
// by a depending on the value of side -- A = P * A if side == Side.left,
// A = A * Pᵀ if side == Side.right.
//
// The exact value of P depends on the value of pivot, but in all cases P is
// implicitly represented by a series of 2×2 rotation matrices. The entries of
// rotation matrix k are defined by s[k] and c[k]
//
//	R(k) = [ c[k] s[k]]
//	       [-s[k] s[k]]
//
// If direct == Direct.forward, the rotation matrices are applied as
// P = P(z-1) * ... * P(2) * P(1), while if direct == Direct.backward they are
// applied as P = P(1) * P(2) * ... * P(n).
//
// pivot defines the mapping of the elements in R(k) to P(k).
// If pivot == Pivot.variable, the rotation is performed for the (k, k+1) plane.
//
//	P(k) = [1                    ]
//	       [    ...              ]
//	       [     1               ]
//	       [       c[k] s[k]     ]
//	       [      -s[k] c[k]     ]
//	       [                 1   ]
//	       [                ...  ]
//	       [                    1]
//
// if pivot == Pivot.top, the rotation is performed for the (1, k+1) plane,
//
//	P(k) = [c[k]        s[k]     ]
//	       [    1                ]
//	       [     ...             ]
//	       [         1           ]
//	       [-s[k]       c[k]     ]
//	       [                 1   ]
//	       [                ...  ]
//	       [                    1]
//
// and if pivot == Pivot.bottom, the rotation is performed for the (k, z) plane.
//
//	P(k) = [1                    ]
//	       [  ...                ]
//	       [      1              ]
//	       [        c[k]     s[k]]
//	       [           1         ]
//	       [            ...      ]
//	       [              1      ]
//	       [       -s[k]     c[k]]
//
// s and c have length m - 1 if side == Side.left, and n - 1 if side == Side.right.
//
pub fn dlasr(side blas.Side, pivot Pivot, direct Direct, m int, n int, c []f64, s []f64, mut a []f64, lda int) {
	if side != .left && side != .right {
		panic(bad_side)
	}
	if pivot != .variable && pivot != .top && pivot != .bottom {
		panic(bad_pivot)
	}
	if direct != .forward && direct != .backward {
		panic(bad_direct)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	if side == .left {
		if c.len < m - 1 {
			panic(short_c)
		}
		if s.len < m - 1 {
			panic(short_s)
		}
	} else {
		if c.len < n - 1 {
			panic(short_c)
		}
		if s.len < n - 1 {
			panic(short_s)
		}
	}
	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}

	if side == .left {
		if pivot == .variable {
			if direct == .forward {
				for j := 0; j < m - 1; j++ {
					ctmp := c[j]
					stmp := s[j]
					if ctmp != 1 || stmp != 0 {
						for i := 0; i < n; i++ {
							tmp2 := a[j * lda + i]
							tmp := a[(j + 1) * lda + i]
							a[(j + 1) * lda + i] = ctmp * tmp - stmp * tmp2
							a[j * lda + i] = stmp * tmp + ctmp * tmp2
						}
					}
				}
				return
			}
			for j := m - 2; j >= 0; j-- {
				ctmp := c[j]
				stmp := s[j]
				if ctmp != 1 || stmp != 0 {
					for i := 0; i < n; i++ {
						tmp2 := a[j * lda + i]
						tmp := a[(j + 1) * lda + i]
						a[(j + 1) * lda + i] = ctmp * tmp - stmp * tmp2
						a[j * lda + i] = stmp * tmp + ctmp * tmp2
					}
				}
			}
			return
		} else if pivot == .top {
			if direct == .forward {
				for j := 1; j < m; j++ {
					ctmp := c[j - 1]
					stmp := s[j - 1]
					if ctmp != 1 || stmp != 0 {
						for i := 0; i < n; i++ {
							tmp := a[j * lda + i]
							tmp2 := a[i]
							a[j * lda + i] = ctmp * tmp - stmp * tmp2
							a[i] = stmp * tmp + ctmp * tmp2
						}
					}
				}
				return
			}
			for j := m - 1; j >= 1; j-- {
				ctmp := c[j - 1]
				stmp := s[j - 1]
				if ctmp != 1 || stmp != 0 {
					for i := 0; i < n; i++ {
						tmp := a[j * lda + i]
						tmp2 := a[i]
						a[j * lda + i] = ctmp * tmp - stmp * tmp2
						a[i] = stmp * tmp + ctmp * tmp2
					}
				}
			}
			return
		}
		if direct == .forward {
			for j := 0; j < m - 1; j++ {
				ctmp := c[j]
				stmp := s[j]
				if ctmp != 1 || stmp != 0 {
					for i := 0; i < n; i++ {
						tmp := a[j * lda + i]
						tmp2 := a[(m - 1) * lda + i]
						a[j * lda + i] = stmp * tmp2 + ctmp * tmp
						a[(m - 1) * lda + i] = ctmp * tmp2 - stmp * tmp
					}
				}
			}
			return
		}
		for j := m - 2; j >= 0; j-- {
			ctmp := c[j]
			stmp := s[j]
			if ctmp != 1 || stmp != 0 {
				for i := 0; i < n; i++ {
					tmp := a[j * lda + i]
					tmp2 := a[(m - 1) * lda + i]
					a[j * lda + i] = stmp * tmp2 + ctmp * tmp
					a[(m - 1) * lda + i] = ctmp * tmp2 - stmp * tmp
				}
			}
		}
		return
	}
	if pivot == .variable {
		if direct == .forward {
			for j := 0; j < n - 1; j++ {
				ctmp := c[j]
				stmp := s[j]
				if ctmp != 1 || stmp != 0 {
					for i := 0; i < m; i++ {
						tmp := a[i * lda + j + 1]
						tmp2 := a[i * lda + j]
						a[i * lda + j + 1] = ctmp * tmp - stmp * tmp2
						a[i * lda + j] = stmp * tmp + ctmp * tmp2
					}
				}
			}
			return
		}
		for j := n - 2; j >= 0; j-- {
			ctmp := c[j]
			stmp := s[j]
			if ctmp != 1 || stmp != 0 {
				for i := 0; i < m; i++ {
					tmp := a[i * lda + j + 1]
					tmp2 := a[i * lda + j]
					a[i * lda + j + 1] = ctmp * tmp - stmp * tmp2
					a[i * lda + j] = stmp * tmp + ctmp * tmp2
				}
			}
		}
		return
	} else if pivot == .top {
		if direct == .forward {
			for j := 1; j < n; j++ {
				ctmp := c[j - 1]
				stmp := s[j - 1]
				if ctmp != 1 || stmp != 0 {
					for i := 0; i < m; i++ {
						tmp := a[i * lda + j]
						tmp2 := a[i * lda]
						a[i * lda + j] = ctmp * tmp - stmp * tmp2
						a[i * lda] = stmp * tmp + ctmp * tmp2
					}
				}
			}
			return
		}
		for j := n - 1; j >= 1; j-- {
			ctmp := c[j - 1]
			stmp := s[j - 1]
			if ctmp != 1 || stmp != 0 {
				for i := 0; i < m; i++ {
					tmp := a[i * lda + j]
					tmp2 := a[i * lda]
					a[i * lda + j] = ctmp * tmp - stmp * tmp2
					a[i * lda] = stmp * tmp + ctmp * tmp2
				}
			}
		}
		return
	}
	if direct == .forward {
		for j := 0; j < n - 1; j++ {
			ctmp := c[j]
			stmp := s[j]
			if ctmp != 1 || stmp != 0 {
				for i := 0; i < m; i++ {
					tmp := a[i * lda + j]
					tmp2 := a[i * lda + n - 1]
					a[i * lda + j] = stmp * tmp2 + ctmp * tmp
					a[i * lda + n - 1] = ctmp * tmp2 - stmp * tmp
				}
			}
		}
		return
	}
	for j := n - 2; j >= 0; j-- {
		ctmp := c[j]
		stmp := s[j]
		if ctmp != 1 || stmp != 0 {
			for i := 0; i < m; i++ {
				tmp := a[i * lda + j]
				tmp2 := a[i * lda + n - 1]
				a[i * lda + j] = stmp * tmp2 + ctmp * tmp
				a[i * lda + n - 1] = ctmp * tmp2 - stmp * tmp
			}
		}
	}
}
