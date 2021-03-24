module vlas

// Panic strings used during parameter checks.
// This list is duplicated in netlib/blas/netlib. Keep in sync.
pub const (
	zero_incx = "blas: zero x index increment"
	zero_incy = "blas: zero y index increment"

	mlt0  = "blas: m < 0"
	nlt0  = "blas: n < 0"
	klt0  = "blas: k < 0"
	kllt0 = "blas: kl < 0"
	kult0 = "blas: ku < 0"

	bad_uplo      = "blas: illegal triangle"
	bad_transpose = "blas: illegal transpose"
	bad_diag      = "blas: illegal diagonal"
	bad_side      = "blas: illegal side"
	bad_flag      = "blas: illegal rotm flag"

	bad_ld_a = "blas: bad leading dimension of A"
	bad_ld_b = "blas: bad leading dimension of B"
	bad_ld_c = "blas: bad leading dimension of C"

	short_x   = "blas: insufficient length of x"
	short_y   = "blas: insufficient length of y"
	short_ap  = "blas: insufficient length of ap"
	short_a   = "blas: insufficient length of a"
	short_b   = "blas: insufficient length of b"
	short_c   = "blas: insufficient length of c"
)
