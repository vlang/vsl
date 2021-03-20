module vlas

pub const (
	lapack_row_major    = 101
	lapack_col_major    = 102
	cblas_row_major     = u32(101)
	cblas_col_major     = u32(102)
	cblas_no_trans      = u32(111)
	cblas_trans         = u32(112)
	cblas_conj_trans    = u32(113)
	cblas_conj_no_trans = u32(114)
	cblas_upper         = u32(121)
	cblas_lower         = u32(122)
	cblas_non_unit      = u32(131)
	cblas_unit          = u32(132)
	cblas_left          = u32(141)
	cblas_right         = u32(142)
)
