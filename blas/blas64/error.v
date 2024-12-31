module blas64

// Panic strings used during parameter checks.
// This list is duplicated in netlib/blas/netlib. Keep in sync.

pub const zero_incx = 'blas: zero x index increment'
pub const zero_incy = 'blas: zero y index increment'

pub const mlt0 = 'blas: m < 0'
pub const nlt0 = 'blas: n < 0'
pub const klt0 = 'blas: k < 0'
pub const kllt0 = 'blas: kl < 0'
pub const kult0 = 'blas: ku < 0'

pub const bad_uplo = 'blas: illegal triangle'
pub const bad_transpose = 'blas: illegal transpose'
pub const bad_diag = 'blas: illegal diagonal'
pub const bad_side = 'blas: illegal side'
pub const bad_flag = 'blas: illegal rotm flag'

pub const bad_ld_a = 'blas: bad leading dimension of A'
pub const bad_ld_b = 'blas: bad leading dimension of B'
pub const bad_ld_c = 'blas: bad leading dimension of C'

pub const short_x = 'blas: insufficient length of x'
pub const short_y = 'blas: insufficient length of y'
pub const short_ap = 'blas: insufficient length of ap'
pub const short_a = 'blas: insufficient length of a'
pub const short_b = 'blas: insufficient length of b'
pub const short_c = 'blas: insufficient length of c'
