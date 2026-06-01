module blas64

// Panic strings used during parameter checks.
// This list is duplicated in netlib/blas/netlib. Keep in sync.

// zero_incx is a public constant used by this module.
pub const zero_incx = 'blas: zero x index increment'
// zero_incy is a public constant used by this module.
pub const zero_incy = 'blas: zero y index increment'

// mlt0 is a public constant used by this module.
pub const mlt0 = 'blas: m < 0'
// nlt0 is a public constant used by this module.
pub const nlt0 = 'blas: n < 0'
// klt0 is a public constant used by this module.
pub const klt0 = 'blas: k < 0'
// kllt0 is a public constant used by this module.
pub const kllt0 = 'blas: kl < 0'
// kult0 is a public constant used by this module.
pub const kult0 = 'blas: ku < 0'

// bad_uplo is a public constant used by this module.
pub const bad_uplo = 'blas: illegal triangle'
// bad_transpose is a public constant used by this module.
pub const bad_transpose = 'blas: illegal transpose'
// bad_diag is a public constant used by this module.
pub const bad_diag = 'blas: illegal diagonal'
// bad_side is a public constant used by this module.
pub const bad_side = 'blas: illegal side'
// bad_flag is a public constant used by this module.
pub const bad_flag = 'blas: illegal rotm flag'

// bad_ld_a is a public constant used by this module.
pub const bad_ld_a = 'blas: bad leading dimension of A'
// bad_ld_b is a public constant used by this module.
pub const bad_ld_b = 'blas: bad leading dimension of B'
// bad_ld_c is a public constant used by this module.
pub const bad_ld_c = 'blas: bad leading dimension of C'

// short_x is a public constant used by this module.
pub const short_x = 'blas: insufficient length of x'
// short_y is a public constant used by this module.
pub const short_y = 'blas: insufficient length of y'
// short_ap is a public constant used by this module.
pub const short_ap = 'blas: insufficient length of ap'
// short_a is a public constant used by this module.
pub const short_a = 'blas: insufficient length of a'
// short_b is a public constant used by this module.
pub const short_b = 'blas: insufficient length of b'
// short_c is a public constant used by this module.
pub const short_c = 'blas: insufficient length of c'
