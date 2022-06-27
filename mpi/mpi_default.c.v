module mpi

import vsl.errors
import math.complex

// is_on tells whether MPI is on or not
//  note: this returns true even after stop
pub fn is_on() bool {
	return false
}

// start initialises MPI
pub fn start() ? {
	return errors.error('MPI is not supported on this platform', .efailed)
}

// stop finalises MPI
pub fn stop() {
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

// new_communicator creates a new communicator or returns the World Communicator
//   ranks -- World indices of processors in this Communicator.
//            use nil or empty to get the World Communicator
pub fn new_communicator(ranks []int) ?&Communicator {
	return errors.error('MPI is not supported on this platform', .efailed)
}

// rank returns the processor rank/ID
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

// bcast_from_root broadcasts slice from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root(x []f64) {
}

// bcast_from_root_c broadcasts slice from root (Rank == 0) to all other processors (complex version)
pub fn (o &Communicator) bcast_from_root_c(x []complex.Complex) {
}

// reduce_sum sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum(mut dest []f64, orig []f64) {
}

// reduce_sum_c sums all values in 'orig' to 'dest' in root (Rank == 0) processor (complex version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_c(mut dest []complex.Complex, orig []complex.Complex) {
}

// all_reduce_sum combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum(mut dest []f64, orig []f64) {
}

// all_reduce_sum_c combines all values from orig into dest summing values (complex version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_c(mut dest []complex.Complex, orig []complex.Complex) {
}

// all_reduce_min combines all values from orig into dest picking minimum values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min(mut dest []f64, orig []f64) {
}

// all_reduce_max combines all values from orig into dest picking minimum values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max(mut dest []f64, orig []f64) {
}

// all_reduce_min_i combines all values from orig into dest picking minimum values (integer version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i(mut dest []int, orig []int) {
}

// all_reduce_max_i combines all values from orig into dest picking minimum values (integer version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i(mut dest []int, orig []int) {
}

// send sends values to processor toID
pub fn (o &Communicator) send(vals []f64, to_id int) {
}

// recv receives values from processor fromId
pub fn (o &Communicator) recv(vals []f64, from_id int) {
}

// send_c sends values to processor toID (complex version)
pub fn (o &Communicator) send_c(vals []complex.Complex, to_id int) {
}

// recv_c receives values from processor fromId (complex version)
pub fn (o &Communicator) recv_c(vals []complex.Complex, from_id int) {
}

// send_i sends values to processor toID (integer version)
pub fn (o &Communicator) send_i(vals []int, to_id int) {
}

// recv_i receives values from processor fromId (integer version)
pub fn (o &Communicator) recv_i(vals []int, from_id int) {
}

// send_one sends one value to processor toID
pub fn (o &Communicator) send_one(val f64, to_id int) {
}

// recv_one receives one value from processor fromId
pub fn (o &Communicator) recv_one(from_id int) f64 {
	return 0
}

// send_one_i sends one value to processor toID (integer version)
pub fn (o &Communicator) send_one_i(val int, to_id int) {
}

// recv_one_i receives one value from processor fromId (integer version)
pub fn (o &Communicator) recv_one_i(from_id int) int {
	return 0
}
