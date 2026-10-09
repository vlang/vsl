module lapack

import vsl.lapack.lapack64

pub fn dlange(norm rune, m int, n int, a []f64, lda int, work []f64) f64 {
	selected_norm := match norm {
		`M` { lapack64.MatrixNorm.max_abs }
		`1`, `O` { lapack64.MatrixNorm.max_column_sum }
		`I` { lapack64.MatrixNorm.max_row_sum }
		`F`, `E` { lapack64.MatrixNorm.frobenius }
		else { panic('dlange: invalid norm') }
	}
	mut workspace := work.clone()
	return lapack64.dlange(selected_norm, m, n, a, lda, mut workspace)
}
