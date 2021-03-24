module vlas

pub type Transpose = u32

pub type Uplo = u32

pub type Diagonal = u32

pub const (
	lapack_row_major   = 101
	lapack_col_major   = 102
	blas_row_major     = u32(101)
	blas_col_major     = u32(102)
	blas_no_trans      = Transpose(111)
	blas_trans         = Transpose(112)
	blas_conj_trans    = Transpose(113)
	blas_conj_no_trans = Transpose(114)
	blas_upper         = Uplo(121)
	blas_lower         = Uplo(122)
	blas_non_unit      = Diagonal(131)
	blas_unit          = Diagonal(132)
	blas_left          = u32(141)
	blas_right         = u32(142)
)
