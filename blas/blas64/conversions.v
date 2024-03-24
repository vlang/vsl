module blas64

// MemoryLayout is used to specify the memory layout of a matrix.
pub enum MemoryLayout {
	row_major = 101
	col_major = 102
}

// Transpose is used to specify the transposition of a matrix.
pub enum Transpose {
	no_trans      = 111
	trans         = 112
	conj_trans    = 113
	conj_no_trans = 114
}

// Uplo is used to specify whether the upper or lower triangle of a matrix is
pub enum Uplo {
	upper = 121
	lower = 122
}

// Diagonal is used to specify whether the diagonal of a matrix is unit or non-unit.
pub enum Diagonal {
	non_unit = 131
	unit     = 132
}

// Side is used to specify whether a matrix is on the left or right side in a matrix-matrix multiplication.
pub enum Side {
	left  = 141
	right = 142
}
