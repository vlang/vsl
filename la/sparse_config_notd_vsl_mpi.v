module la

import vsl.errors

// The SparseConfig structure holds configuration arguments for sparse solvers
pub struct SparseConfig {
mut:
	mumps_ordering int  // ICNTL(7) default = "" == "auto"
	mumps_scaling  int  // Scaling type (check MUMPS solver) [may be empty]
	symmetric      bool // indicates symmetric system. NOTE: when using MUMPS, only the upper or lower part of the matrix must be provided
	sym_pos_def    bool // indicates symmetric-positive-defined system. NOTE: when using MUMPS, only the upper or lower part of the matrix must be provided
pub mut:
	verbose                             bool // run on verbose mode
	mumps_increase_of_working_space_pct int  // MUMPS control parameters (check MUMPS solver manual) ICNTL(14) default = 100%
	mumps_max_memory_per_processor      int  // MUMPS control parameters (check MUMPS solver manual) ICNTL(23) default = 2000Mb
}

// SparseConfig.new returns a new SparseConfig
pub fn SparseConfig.new() SparseConfig {
	mut o := SparseConfig{
		mumps_increase_of_working_space_pct: 100
		mumps_max_memory_per_processor:      2000
	}
	o.set_mumps_ordering('')
	o.set_mumps_scaling('')
	return o
}

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
pub fn (mut o SparseConfig) set_mumps_ordering(ordering string) {
	match ordering {
		'amd' { o.mumps_ordering = 0 }
		'', 'amf' { o.mumps_ordering = 2 }
		'scotch' { o.mumps_ordering = 3 }
		'pord' { o.mumps_ordering = 4 }
		'metis' { o.mumps_ordering = 5 }
		'qamd' { o.mumps_ordering = 6 }
		'auto' { o.mumps_ordering = 7 }
		else { errors.vsl_panic('ordering scheme ${ordering} is not available\n', .efailed) }
	}
}

// set_mumps_scaling sets scaling for MUMPS solver
pub fn (mut o SparseConfig) set_mumps_scaling(scaling string) {
	match scaling {
		'no' { o.mumps_scaling = 0 } // no scaling
		'diag' { o.mumps_scaling = 1 } // diagonal scaling
		'col' { o.mumps_scaling = 3 } // column
		'rcinf' { o.mumps_scaling = 4 } // row and column based on inf norms
		'', 'rcit' { o.mumps_scaling = 7 } // row/col iterative
		'rrcit' { o.mumps_scaling = 8 } // rigorous row/col it
		'auto' { o.mumps_scaling = 77 } // automatic
		else { errors.vsl_panic('scaling scheme ${scaling} is not available\n', .efailed) }
	}
}
