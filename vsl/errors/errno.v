module errors

pub enum ErrorCode {
	// success
	success = 0
	// generic failure
	failure = -1
	// iteration has not converged
	can_continue = -2
	// input domain error, e.g sqrt(-1)
	edom = 1
	// output range error, e.g. exp(1e+100)
	erange = 2
	// invalid pointer
	efault = 3
	// invalid argument supplied by user
	einval = 4
	// generic failure
	efailed = 5
	// factorization failed
	efactor = 6
	// sanity check failed - shouldn't happen
	esanity = 7
	// malloc failed
	enomem = 8
	// problem with user-supplied function
	ebadfunc = 9
	// iterative process is out of control
	erunaway = 10
	// exceeded max number of iterations
	emaxiter = 11
	// tried to divide by zero
	ezerodiv = 12
	// user specified an invalid tolerance
	ebadtol = 13
	// failed to reach the specified tolerance
	etol = 14
	// underflow
	eundrflw = 15
	// overflow
	eovrflw = 16
	// loss of accuracy
	eloss = 17
	// failed because of roundoff error
	eround = 18
	// matrix, vector lengths are not conformant
	ebadlen = 19
	// matrix not square
	enotsqr = 20
	// apparent singularity detected
	esing = 21
	// integral or series is divergent
	ediverge = 22
	// requested feature is not supported by the hardware
	eunsup = 23
	// requested feature not (yet) implemented
	eunimpl = 24
	// cache limit exceeded
	ecache = 25
	// table limit exceeded
	etable = 26
	// iteration is not making progress towards solution
	enoprog = 27
	// jacobian evaluations are not improving the solution
	enoprogj = 28
	// cannot reach the specified tolerance in F
	etolf = 29
	// cannot reach the specified tolerance in X
	etolx = 30
	// cannot reach the specified tolerance in gradient
	etolg = 31
	// end of file
	eof = 32
}
