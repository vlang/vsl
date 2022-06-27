module la

import vsl.errors
// import vsl.mpi

// The SparseConfig structure holds configuration arguments for sparse solvers
pub struct SparseConfig {
mut:
	mumps_ordering int // ICNTL(7) default = "" == "auto"
	mumps_scaling  int // Scaling type (check MUMPS solver) [may be empty]
        // communicator &mpi.Communicator = 0 // MPI communicator for parallel solvers [may be nil]
	// internal
	symmetric   bool // indicates symmetric system. NOTE: when using MUMPS, only the upper or lower part of the matrix must be provided
	sym_pos_def bool // indicates symmetric-positive-defined system. NOTE: when using MUMPS, only the upper or lower part of the matrix must be provided
pub mut:
	// external
	verbose bool // run on verbose mode
	// MUMPS control parameters (check MUMPS solver manual)
	mumps_increase_of_working_space_pct int // ICNTL(14) default = 100%
	mumps_max_memory_per_processor      int // ICNTL(23) default = 2000Mb
}

// new_sparse_config returns a new SparseConfig
// Input:
//  comm -- may be nil
pub fn new_sparse_config() SparseConfig {
	mut o := SparseConfig{
		mumps_increase_of_working_space_pct: 100
		mumps_max_memory_per_processor: 2000
	}
	o.set_mumps_ordering('')
	o.set_mumps_scaling('')
	return o
}

// new_sparse_config_with_comm returns a new SparseConfig
// Input:
//  comm -- may be nil
// pub fn new_sparse_config_with_comm(comm &mpi.Communicator) SparseConfig {
// 	mut o := SparseConfig{
// 		mumps_increase_of_working_space_pct: 100
// 		mumps_max_memory_per_processor: 2000
//                 communicator: unsafe{ comm }
// 	}
// 	o.set_mumps_ordering('')
// 	o.set_mumps_scaling('')
// 	return o
// }

// set_mumps_symmetry sets symmetry options for MUMPS solver
pub fn (mut o SparseConfig) set_mumps_symmetry(only_upper_or_lower_given bool, positive_defined bool) {
	if !only_upper_or_lower_given {
		errors.vsl_panic('when using MUMPS, only the upper or the lower part of the matrix (including diagonal) must be given in the Triplet',
			.efailed)
	}
	o.symmetric = true
	if positive_defined {
		o.sym_pos_def = true
	}
}

// set_umfpack_symmetry sets symmetry options for UMFPACK solver
pub fn (mut o SparseConfig) set_umfpack_symmetry() {
	o.symmetric = true
}

// set_mumps_ordering sets ordering for MUMPS solver
// ordering -- "" or "amf" [default]
//             "amf", "scotch", "pord", "metis", "qamd", "auto"
// ICNTL(7)
//   0: "amd" Approximate Minimum Degree (AMD)
//   2: "amf" Approximate Minimum Fill (AMF)
//   3: "scotch" SCOTCH5 package is used if previously installed by the user otherwise treated as 7.
//   4: "pord" PORD6 is used if previously installed by the user otherwise treated as 7.
//   5: "metis" Metis7 package is used if previously installed by the user otherwise treated as 7.
//   6: "qamd" Approximate Minimum Degree with automatic quasi-dense row detection (QAMD) is used.
//   7: "auto" automatic choice by the software during analysis phase. This choice will depend on the
//       ordering packages made available, on the matrix (type and size), and on the number of processors.
pub fn (mut o SparseConfig) set_mumps_ordering(ordering string) {
	match ordering {
		'amd' { o.mumps_ordering = 0 }
		'', 'amf' { o.mumps_ordering = 2 }
		'scotch' { o.mumps_ordering = 3 }
		'pord' { o.mumps_ordering = 4 }
		'metis' { o.mumps_ordering = 5 }
		'qamd' { o.mumps_ordering = 6 }
		'auto' { o.mumps_ordering = 7 }
		else { errors.vsl_panic('ordering scheme $ordering is not available\n', .efailed) }
	}
}

// set_mumps_scaling sets scaling for MUMPS solver
// scaling -- "" or "rcit" [default]
//            "no", "diag", "col", "rcinf", "rcit", "rrcit", "auto"
// ICNTL(8)
//   0: "no" No scaling applied/computed.
//   1: "diag" Diagonal scaling computed during the numerical factorization phase,
//   3: "col" Column scaling computed during the numerical factorization phase,
//   4: "rcinf" Row and column scaling based on infinite row/column norms, computed during the numerical
//      factorization phase,
//   7: "rcit" Simultaneous row and column iterative scaling based on [41] and [15] computed during the
//      numerical factorization phase.
//   8: "rrcit" Similar to 7 but more rigorous and expensive to compute; computed during the numerical
//      factorization phase.
//   77: "auto" Automatic choice of the value of ICNTL(8) done during analy
pub fn (mut o SparseConfig) set_mumps_scaling(scaling string) {
	match scaling {
		'no' { o.mumps_scaling = 0 } // no scaling
		'diag' { o.mumps_scaling = 1 } // diagonal scaling
		'col' { o.mumps_scaling = 3 } // column
		'rcinf' { o.mumps_scaling = 4 } // row and column based on inf norms
		'', 'rcit' { o.mumps_scaling = 7 } // row/col iterative
		'rrcit' { o.mumps_scaling = 8 } // rigorous row/col it
		'auto' { o.mumps_scaling = 77 } // automatic
		else { errors.vsl_panic('scaling scheme $scaling is not available\n', .efailed) }
	}
}
