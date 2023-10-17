module mpi

import vsl.errors
import math.complex

fn init() {
	println('MPI is not supported on this platform')
}

// is_on tells whether MPI is on or not
//  note: this returns true even after stop
pub fn is_on() bool {
	return false
}

// initialize initialises MPI
pub fn initialize() ! {
	return errors.error('MPI is not supported on this platform', .efailed)
}

// initialise initialises MPI
pub fn initialise() ! {
	return errors.error('MPI is not supported on this platform', .efailed)
}

// finalize finalises MPI
pub fn finalize() {
}

// world_rank returns the processor rank/ID within the World Communicator
pub fn world_rank() int {
	return 0
}

// world_size returns the number of processors in the World Communicator
pub fn world_size() int {
	return 0
}

// Communicator holds the World Communicator or a subset Communicator
pub struct Communicator {}

// Communicator.new creates a new communicator or returns the World Communicator
//   ranks -- World indices of processors in this Communicator.
//            use nil or empty to get the World Communicator
pub fn Communicator.new(ranks []int) !&Communicator {
	return errors.error('MPI is not supported on this platform', .efailed)
}

// rank returns the processor rank
pub fn (o &Communicator) rank() int {
	return 0
}

// size returns the number of processors
pub fn (o &Communicator) size() int {
	return 0
}

// abort aborts MPI
pub fn (o &Communicator) abort() {
}

// barrier forces synchronisation
pub fn (o &Communicator) barrier() {
}

// insert codegen functions here:

// send_i32 sends values to processor to_rank
pub fn (o &Communicator) send_i32(vals []i32, to_rank int) {
}

// recv_i32 receives values from processor from_rank
pub fn (o &Communicator) recv_i32(vals []i32, from_rank int) {
}

// send_u32 sends values to processor to_rank
pub fn (o &Communicator) send_u32(vals []u32, to_rank int) {
}

// recv_u32 receives values from processor from_rank
pub fn (o &Communicator) recv_u32(vals []u32, from_rank int) {
}

// send_i64 sends values to processor to_rank
pub fn (o &Communicator) send_i64(vals []i64, to_rank int) {
}

// recv_i64 receives values from processor from_rank
pub fn (o &Communicator) recv_i64(vals []i64, from_rank int) {
}

// send_u64 sends values to processor to_rank
pub fn (o &Communicator) send_u64(vals []u64, to_rank int) {
}

// recv_u64 receives values from processor from_rank
pub fn (o &Communicator) recv_u64(vals []u64, from_rank int) {
}

// send_f32 sends values to processor to_rank
pub fn (o &Communicator) send_f32(vals []f32, to_rank int) {
}

// recv_f32 receives values from processor from_rank
pub fn (o &Communicator) recv_f32(vals []f32, from_rank int) {
}

// send_f64 sends values to processor to_rank
pub fn (o &Communicator) send_f64(vals []f64, to_rank int) {
}

// recv_f64 receives values from processor from_rank
pub fn (o &Communicator) recv_f64(vals []f64, from_rank int) {
}

// send_one_i32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_i32(val i32, to_rank int) {
}

// recv_one_i32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_i32(from_rank int) i32 {
	return i32(0)
}

// send_one_u32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_u32(val u32, to_rank int) {
}

// recv_one_u32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_u32(from_rank int) u32 {
	return u32(0)
}

// send_one_i64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_i64(val i64, to_rank int) {
}

// recv_one_i64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_i64(from_rank int) i64 {
	return i64(0)
}

// send_one_u64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_u64(val u64, to_rank int) {
}

// recv_one_u64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_u64(from_rank int) u64 {
	return u64(0)
}

// send_one_f32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_f32(val f32, to_rank int) {
}

// recv_one_f32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_f32(from_rank int) f32 {
	return f32(0)
}

// send_one_f64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_f64(val f64, to_rank int) {
}

// recv_one_f64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_f64(from_rank int) f64 {
	return f64(0)
}

// bcast_from_root_i32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_i32(x []i32) {
}

// bcast_from_root_u32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_u32(x []u32) {
}

// bcast_from_root_i64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_i64(x []i64) {
}

// bcast_from_root_u64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_u64(x []u64) {
}

// bcast_from_root_f32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_f32(x []f32) {
}

// bcast_from_root_f64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_f64(x []f64) {
}

// reduce_sum_i32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_i32(mut dest []i32, orig []i32) {
}

// all_reduce_sum_i32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_i32(mut dest []i32, orig []i32) {
}

// reduce_min_i32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_i32(mut dest []i32, orig []i32) {
}

// all_reduce_min_i32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i32(mut dest []i32, orig []i32) {
}

// reduce_max_i32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_i32(mut dest []i32, orig []i32) {
}

// all_reduce_max_i32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i32(mut dest []i32, orig []i32) {
}

// reduce_sum_u32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_u32(mut dest []u32, orig []u32) {
}

// all_reduce_sum_u32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_u32(mut dest []u32, orig []u32) {
}

// reduce_min_u32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_u32(mut dest []u32, orig []u32) {
}

// all_reduce_min_u32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_u32(mut dest []u32, orig []u32) {
}

// reduce_max_u32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_u32(mut dest []u32, orig []u32) {
}

// all_reduce_max_u32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_u32(mut dest []u32, orig []u32) {
}

// reduce_sum_i64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_i64(mut dest []i64, orig []i64) {
}

// all_reduce_sum_i64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_i64(mut dest []i64, orig []i64) {
}

// reduce_min_i64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_i64(mut dest []i64, orig []i64) {
}

// all_reduce_min_i64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i64(mut dest []i64, orig []i64) {
}

// reduce_max_i64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_i64(mut dest []i64, orig []i64) {
}

// all_reduce_max_i64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i64(mut dest []i64, orig []i64) {
}

// reduce_sum_u64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_u64(mut dest []u64, orig []u64) {
}

// all_reduce_sum_u64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_u64(mut dest []u64, orig []u64) {
}

// reduce_min_u64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_u64(mut dest []u64, orig []u64) {
}

// all_reduce_min_u64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_u64(mut dest []u64, orig []u64) {
}

// reduce_max_u64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_u64(mut dest []u64, orig []u64) {
}

// all_reduce_max_u64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_u64(mut dest []u64, orig []u64) {
}

// reduce_sum_f32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_f32(mut dest []f32, orig []f32) {
}

// all_reduce_sum_f32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_f32(mut dest []f32, orig []f32) {
}

// reduce_min_f32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_f32(mut dest []f32, orig []f32) {
}

// all_reduce_min_f32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_f32(mut dest []f32, orig []f32) {
}

// reduce_max_f32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_f32(mut dest []f32, orig []f32) {
}

// all_reduce_max_f32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_f32(mut dest []f32, orig []f32) {
}

// reduce_sum_f64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_f64(mut dest []f64, orig []f64) {
}

// all_reduce_sum_f64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_f64(mut dest []f64, orig []f64) {
}

// reduce_min_f64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_f64(mut dest []f64, orig []f64) {
}

// all_reduce_min_f64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_f64(mut dest []f64, orig []f64) {
}

// reduce_max_f64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_f64(mut dest []f64, orig []f64) {
}

// all_reduce_max_f64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_f64(mut dest []f64, orig []f64) {
}
