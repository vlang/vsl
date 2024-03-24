module blas64

// [SD]gemm behavior constants. These are kept here to keep them out of the
// way during single precision code genration.
const block_size = 64 // b x b matrix

const min_par_block = 4 // minimum number of blocks needed to go parallel

// blocks returns the number of divisions of the dimension length with the given
// block size.
fn blocks(dim int, bsize int) int {
	return (dim + bsize - 1) / bsize
}

fn flatten(a [][]f64) []f64 {
	if a.len == 0 {
		return []
	}
	m := a.len
	n := a[0].len
	mut s := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			s[i * n + j] = a[i][j]
		}
	}
	return s
}
