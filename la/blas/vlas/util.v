module vlas

// [SD]gemm behavior constants. These are kept here to keep them out of the
// way during single precision code genration.
const (
	block_size    = 64 // b x b matrix
	min_par_block = 4  // minimum number of blocks needed to go parallel
)

// blocks returns the number of divisions of the dimension length with the given
// block size.
fn blocks(dim int, bsize int) int {
	return (dim + bsize - 1) / bsize
}
