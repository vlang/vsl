module mpi

import vsl.errors
// import math.complex

fn C.MPI_Initialized(flag &int) int
fn C.MPI_Init(argc int, argv &charptr) int
fn C.MPI_Init_thread(argc int, argv &charptr, required int, provided &int) int

type MPI_Comm = voidptr
type MPI_Datatype = voidptr
type MPI_Group = voidptr
type MPI_Status = voidptr
type MPI_Op = voidptr

fn C.MPI_Comm_rank(comm MPI_Comm, rank &int) int
fn C.MPI_Comm_size(comm MPI_Comm, size &int) int
fn C.MPI_Comm_group(comm MPI_Comm, group &MPI_Group) int
fn C.MPI_Group_incl(group MPI_Group, n int, ranks &int, newgroup &MPI_Group) int
fn C.MPI_Comm_create(comm MPI_Comm, group MPI_Group, newcomm &MPI_Comm) int

fn C.MPI_Abort(comm MPI_Comm, errorcode int) int
fn C.MPI_Finalize() int
fn C.MPI_Finalized(flag &int) int
fn C.MPI_Barrier(comm MPI_Comm) int
fn C.MPI_Bcast(buffer &voidptr, count int, datatype MPI_Datatype, root int, comm MPI_Comm) int
fn C.MPI_Reduce(sendbuf &voidptr, recvbuf &voidptr, count int, datatype MPI_Datatype, op MPI_Op, root int, comm MPI_Comm) int
fn C.MPI_Allreduce(sendbuf &voidptr, recvbuf &voidptr, count int, datatype MPI_Datatype, op MPI_Op, comm MPI_Comm) int
fn C.MPI_Send(buf &voidptr, count int, datatype MPI_Datatype, dest int, tag int, comm MPI_Comm) int
fn C.MPI_Recv(buf &voidptr, count int, datatype MPI_Datatype, source int, tag int, comm MPI_Comm, status &MPI_Status) int

// is_on tells whether MPI is on or not
//  note: this returns true even after finish
pub fn is_on() bool {
	flag := 0
	C.MPI_Initialized(&flag)
	return flag != 0
}

// start initialises MPI
[deprecated: 'use initialize instead']
pub fn start() ? {
	C.MPI_Init(0, unsafe { nil })
}

// initialize readies MPI for use
pub fn initialize() ? {
	C.MPI_Init(0, unsafe { nil })
}

// initialise readies MPI for use
pub fn initialise() ? {
	C.MPI_Init(0, unsafe { nil })
}

// start_thread_safe initialises MPI in a thread safe way
pub fn start_thread_safe() ? {
	r := 0
	C.MPI_Init_thread(0, unsafe { nil }, C.MPI_THREAD_MULTIPLE, &r)
	if r != C.MPI_THREAD_MULTIPLE {
		return errors.error("MPI_THREAD_MULTIPLE can't be set: got $r", .efailed)
	}
}

// stop finalises MPI
[deprecated: 'use finalize instead']
pub fn stop() {
	C.MPI_Finalize()
}

// finalize MPI
pub fn finalize() {
	C.MPI_Finalize()
}

// world_rank returns the processor rank within the World Communicator
pub fn world_rank() int {
	r := 0
	C.MPI_Comm_rank(C.MPI_COMM_WORLD, &r)
	return r
}

// world_size returns the number of processors in the World Communicator
pub fn world_size() int {
	r := 0
	C.MPI_Comm_size(C.MPI_COMM_WORLD, &r)
	return r
}

// Communicator holds the World Communicator or a subset Communicator
pub struct Communicator {
mut:
	comm  MPI_Comm
	group MPI_Group
}

// new_communicator creates a new communicator or returns the World Communicator
//   ranks -- World indices of processors in this Communicator.
//            use nil or empty to get the World Communicator
//   Note there is currently no means to use groups.
pub fn new_communicator(ranks []int) ?&Communicator {
	mut o := &Communicator{
		comm: MPI_Comm(C.MPI_COMM_WORLD)
		group: unsafe { nil }
	}
	if ranks.len == 0 {
		C.MPI_Comm_group(C.MPI_COMM_WORLD, &o.group)
		return o
	}

	rs := ranks.clone()
	r := unsafe { &rs[0] }
	wgroup := MPI_Group(0)
	C.MPI_Comm_group(C.MPI_COMM_WORLD, &wgroup)
	C.MPI_Group_incl(wgroup, ranks.len, r, &o.group)
	C.MPI_Comm_create(C.MPI_COMM_WORLD, o.group, &o.comm)
	return o
}

// rank returns the processor rank
pub fn (o &Communicator) rank() int {
	r := 0
	C.MPI_Comm_rank(o.comm, &r)
	return r
}

// size returns the number of processors
pub fn (o &Communicator) size() int {
	r := 0
	C.MPI_Comm_size(o.comm, &r)
	return r
}

// abort aborts MPI
pub fn (o &Communicator) abort() {
	C.MPI_Abort(o.comm, 0)
}

// barrier forces synchronisation
pub fn (o &Communicator) barrier() {
	C.MPI_Barrier(o.comm)
}

// insert codegen functions here:

// send_i32 sends values to processor to_rank
pub fn (o &Communicator) send_i32(vals []i32, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_INT, to_rank, 0, o.comm)
}

// recv_i32 receives values from processor from_rank
pub fn (o &Communicator) recv_i32(vals []i32, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_INT, from_rank, 0, o.comm)
}

// send_u32 sends values to processor to_rank
pub fn (o &Communicator) send_u32(vals []u32, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED, to_rank, 0, o.comm)
}

// recv_u32 receives values from processor from_rank
pub fn (o &Communicator) recv_u32(vals []u32, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED, from_rank, 0, o.comm)
}

// send_i64 sends values to processor to_rank
pub fn (o &Communicator) send_i64(vals []i64, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_LONG, to_rank, 0, o.comm)
}

// recv_i64 receives values from processor from_rank
pub fn (o &Communicator) recv_i64(vals []i64, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_LONG, from_rank, 0, o.comm)
}

// send_u64 sends values to processor to_rank
pub fn (o &Communicator) send_u64(vals []u64, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED_LONG, to_rank, 0, o.comm)
}

// recv_u64 receives values from processor from_rank
pub fn (o &Communicator) recv_u64(vals []u64, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED_LONG, from_rank, 0, o.comm)
}

// send_f32 sends values to processor to_rank
pub fn (o &Communicator) send_f32(vals []f32, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_FLOAT, to_rank, 0, o.comm)
}

// recv_f32 receives values from processor from_rank
pub fn (o &Communicator) recv_f32(vals []f32, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_FLOAT, from_rank, 0, o.comm)
}

// send_f64 sends values to processor to_rank
pub fn (o &Communicator) send_f64(vals []f64, to_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, to_rank, 0, o.comm)
}

// recv_f64 receives values from processor from_rank
pub fn (o &Communicator) recv_f64(vals []f64, from_rank int) {
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, from_rank, 0, o.comm)
}

// send_one_i32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_i32(val i32, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_INT, to_rank, 0, o.comm)
}

// recv_one_i32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_i32(from_rank int) i32 {
	vals := [i32(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_INT, from_rank, 0, o.comm)
	return vals[0]
}

// send_one_u32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_u32(val u32, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED, to_rank, 0, o.comm)
}

// recv_one_u32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_u32(from_rank int) u32 {
	vals := [u32(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED, from_rank, 0, o.comm)
	return vals[0]
}

// send_one_i64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_i64(val i64, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_LONG, to_rank, 0, o.comm)
}

// recv_one_i64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_i64(from_rank int) i64 {
	vals := [i64(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_LONG, from_rank, 0, o.comm)
	return vals[0]
}

// send_one_u64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_u64(val u64, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED_LONG, to_rank, 0, o.comm)
}

// recv_one_u64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_u64(from_rank int) u64 {
	vals := [u64(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_UNSIGNED_LONG, from_rank, 0, o.comm)
	return vals[0]
}

// send_one_f32 sends one value to processor to_rank
pub fn (o &Communicator) send_one_f32(val f32, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_FLOAT, to_rank, 0, o.comm)
}

// recv_one_f32 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_f32(from_rank int) f32 {
	vals := [f32(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_FLOAT, from_rank, 0, o.comm)
	return vals[0]
}

// send_one_f64 sends one value to processor to_rank
pub fn (o &Communicator) send_one_f64(val f64, to_rank int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, to_rank, 0, o.comm)
}

// recv_one_f64 receives one value from processor from_rank
pub fn (o &Communicator) recv_one_f64(from_rank int) f64 {
	vals := [f64(0)]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, from_rank, 0, o.comm)
	return vals[0]
}

// bcast_from_root_i32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_i32(x []i32) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_INT, 0, o.comm)
}

// bcast_from_root_u32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_u32(x []u32) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_UNSIGNED, 0, o.comm)
}

// bcast_from_root_i64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_i64(x []i64) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_LONG, 0, o.comm)
}

// bcast_from_root_u64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_u64(x []u64) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_UNSIGNED_LONG, 0, o.comm)
}

// bcast_from_root_f32 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_f32(x []f32) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_FLOAT, 0, o.comm)
}

// bcast_from_root_f64 broadcasts slice x from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root_f64(x []f64) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_DOUBLE, 0, o.comm)
}

// reduce_sum_i32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_i32(mut dest []i32, orig []i32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum_i32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_i32(mut dest []i32, orig []i32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_SUM,
		o.comm)
}

// reduce_min_i32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_i32(mut dest []i32, orig []i32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MIN,
		0, o.comm)
}

// all_reduce_min_i32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i32(mut dest []i32, orig []i32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MIN,
		o.comm)
}

// reduce_max_i32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_i32(mut dest []i32, orig []i32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MAX,
		0, o.comm)
}

// all_reduce_max_i32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i32(mut dest []i32, orig []i32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MAX,
		o.comm)
}

// reduce_sum_u32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_u32(mut dest []u32, orig []u32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum_u32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_u32(mut dest []u32, orig []u32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED,
		C.MPI_SUM, o.comm)
}

// reduce_min_u32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_u32(mut dest []u32, orig []u32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED, C.MPI_MIN,
		0, o.comm)
}

// all_reduce_min_u32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_u32(mut dest []u32, orig []u32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED,
		C.MPI_MIN, o.comm)
}

// reduce_max_u32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_u32(mut dest []u32, orig []u32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED, C.MPI_MAX,
		0, o.comm)
}

// all_reduce_max_u32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_u32(mut dest []u32, orig []u32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED,
		C.MPI_MAX, o.comm)
}

// reduce_sum_i64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_i64(mut dest []i64, orig []i64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum_i64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_i64(mut dest []i64, orig []i64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_SUM,
		o.comm)
}

// reduce_min_i64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_i64(mut dest []i64, orig []i64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_MIN,
		0, o.comm)
}

// all_reduce_min_i64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i64(mut dest []i64, orig []i64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_MIN,
		o.comm)
}

// reduce_max_i64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_i64(mut dest []i64, orig []i64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_MAX,
		0, o.comm)
}

// all_reduce_max_i64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i64(mut dest []i64, orig []i64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_LONG, C.MPI_MAX,
		o.comm)
}

// reduce_sum_u64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_u64(mut dest []u64, orig []u64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_SUM, 0, o.comm)
}

// all_reduce_sum_u64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_u64(mut dest []u64, orig []u64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_SUM, o.comm)
}

// reduce_min_u64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_u64(mut dest []u64, orig []u64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_MIN, 0, o.comm)
}

// all_reduce_min_u64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_u64(mut dest []u64, orig []u64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_MIN, o.comm)
}

// reduce_max_u64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_u64(mut dest []u64, orig []u64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_MAX, 0, o.comm)
}

// all_reduce_max_u64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_u64(mut dest []u64, orig []u64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_UNSIGNED_LONG,
		C.MPI_MAX, o.comm)
}

// reduce_sum_f32 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_f32(mut dest []f32, orig []f32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum_f32 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_f32(mut dest []f32, orig []f32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_SUM,
		o.comm)
}

// reduce_min_f32 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_f32(mut dest []f32, orig []f32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_MIN,
		0, o.comm)
}

// all_reduce_min_f32 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_f32(mut dest []f32, orig []f32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_MIN,
		o.comm)
}

// reduce_max_f32 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_f32(mut dest []f32, orig []f32) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_MAX,
		0, o.comm)
}

// all_reduce_max_f32 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_f32(mut dest []f32, orig []f32) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_FLOAT, C.MPI_MAX,
		o.comm)
}

// reduce_sum_f64 sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_f64(mut dest []f64, orig []f64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum_f64 combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_f64(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_SUM, o.comm)
}

// reduce_min_f64 minimizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_min_f64(mut dest []f64, orig []f64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE, C.MPI_MIN,
		0, o.comm)
}

// all_reduce_min_f64 minimizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_f64(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_MIN, o.comm)
}

// reduce_max_f64 maximizes all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_max_f64(mut dest []f64, orig []f64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE, C.MPI_MAX,
		0, o.comm)
}

// all_reduce_max_f64 maximizes all values from orig into all dest values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_f64(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_MAX, o.comm)
}
