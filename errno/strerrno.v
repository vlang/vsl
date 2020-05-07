// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module errno

pub fn str_error(errno Errno) string {
	return match errno {
		.success { 'success' }
		.failure { 'failure' }
		.can_continue { 'the iteration has not converged yet' }
		.edom { 'input domain error' }
		.erange { 'output range error' }
		.efault { 'invalid pointer' }
		.einval { 'invalid argument supplied by user' }
		.efailed { 'generic failure' }
		.efactor { 'factorization failed' }
		.esanity { "sanity check failed - shouldn't happen" }
		.enomem { 'malloc failed' }
		.ebadfunc { 'problem with user-supplied function' }
		.erunaway { 'iterative process is out of control' }
		.emaxiter { 'exceeded max number of iterations' }
		.ezerodiv { 'tried to divide by zero' }
		.ebadtol { 'specified tolerance is invalid or theoretically unattainable' }
		.etol { 'failed to reach the specified tolerance' }
		.eundrflw { 'underflow' }
		.eovrflw { 'overflow' }
		.eloss { 'loss of accuracy' }
		.eround { 'roundoff error' }
		.ebadlen { 'matrix/vector sizes are not conformant' }
		.enotsqr { 'matrix not square' }
		.esing { 'singularity or extremely bad function behavior detected' }
		.ediverge { 'integral or series is divergent' }
		.eunsup { 'the required feature is not supported by this hardware platform' }
		.eunimpl { 'the requested feature is not (yet) implemented' }
		.ecache { 'cache limit exceeded' }
		.etable { 'table limit exceeded' }
		.enoprog { 'iteration is not making progress towards solution' }
		.enoprogj { 'jacobian evaluations are not improving the solution' }
		.etolf { 'cannot reach the specified tolerance in F' }
		.etolx { 'cannot reach the specified tolerance in X' }
		.etolg { 'cannot reach the specified tolerance in gradient' }
		.eof { 'end of file' }
		// else { 'unknown error code' }
	}
}
