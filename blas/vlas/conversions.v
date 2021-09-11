module vlas

pub enum MemoryLayout {
	row_major = 101
	col_major = 102
}

pub enum Transpose {
	no_trans = 111
	trans = 112
	conj_trans = 113
	conj_no_trans = 114
}

pub enum Uplo {
	upper = 121
	lower = 122
}

pub enum Diagonal {
	non_unit = 131
	unit = 132
}

pub enum Side {
	left = 141
	right = 142
}
