module errors

struct ErrorCodeCase {
	code    ErrorCode
	value   int
	message string
}

fn test_error_code_values_and_strings() {
	cases := [
		ErrorCodeCase{.success, 0, 'success'},
		ErrorCodeCase{.failure, -1, 'failure'},
		ErrorCodeCase{.can_continue, -2, 'the iteration has not converged yet'},
		ErrorCodeCase{.edom, 1, 'input domain error'},
		ErrorCodeCase{.erange, 2, 'output range error'},
		ErrorCodeCase{.efault, 3, 'invalid pointer'},
		ErrorCodeCase{.einval, 4, 'invalid argument supplied by user'},
		ErrorCodeCase{.efailed, 5, 'generic failure'},
		ErrorCodeCase{.efactor, 6, 'factorization failed'},
		ErrorCodeCase{.esanity, 7, "sanity check failed - shouldn't happen"},
		ErrorCodeCase{.enomem, 8, 'malloc failed'},
		ErrorCodeCase{.ebadfunc, 9, 'problem with user-supplied function'},
		ErrorCodeCase{.erunaway, 10, 'iterative process is out of control'},
		ErrorCodeCase{.emaxiter, 11, 'exceeded max number of iterations'},
		ErrorCodeCase{.ezerodiv, 12, 'tried to divide by zero'},
		ErrorCodeCase{.ebadtol, 13, 'specified tolerance is invalid or theoretically unattainable'},
		ErrorCodeCase{.etol, 14, 'failed to reach the specified tolerance'},
		ErrorCodeCase{.eundrflw, 15, 'underflow'},
		ErrorCodeCase{.eovrflw, 16, 'overflow'},
		ErrorCodeCase{.eloss, 17, 'loss of accuracy'},
		ErrorCodeCase{.eround, 18, 'roundoff error'},
		ErrorCodeCase{.ebadlen, 19, 'matrix/vector sizes are not conformant'},
		ErrorCodeCase{.enotsqr, 20, 'matrix not square'},
		ErrorCodeCase{.esing, 21, 'singularity or extremely bad function behavior detected'},
		ErrorCodeCase{.ediverge, 22, 'integral or series is divergent'},
		ErrorCodeCase{.eunsup, 23, 'the required feature is not supported by this hardware platform'},
		ErrorCodeCase{.eunimpl, 24, 'the requested feature is not (yet) implemented'},
		ErrorCodeCase{.ecache, 25, 'cache limit exceeded'},
		ErrorCodeCase{.etable, 26, 'table limit exceeded'},
		ErrorCodeCase{.enoprog, 27, 'iteration is not making progress towards solution'},
		ErrorCodeCase{.enoprogj, 28, 'jacobian evaluations are not improving the solution'},
		ErrorCodeCase{.etolf, 29, 'cannot reach the specified tolerance in F'},
		ErrorCodeCase{.etolx, 30, 'cannot reach the specified tolerance in X'},
		ErrorCodeCase{.etolg, 31, 'cannot reach the specified tolerance in gradient'},
		ErrorCodeCase{.eof, 32, 'end of file'},
	]
	assert cases.len == 35
	for case in cases {
		assert int(case.code) == case.value
		assert case.code.str() == case.message
	}
}

fn test_error_message_includes_reason_and_code() {
	assert error_message('matrix must be square', .enotsqr) == 'VSL Error: (matrix not square) matrix must be square'
}
