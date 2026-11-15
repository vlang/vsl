module integrate

import math
import vsl.func
import vsl.internal.prec

const kronrod_nodes = [
	f64(0.991455371120812639206854697526329),
	0.949107912342758524526189684047851,
	0.864864423359769072789712788640926,
	0.741531185599394439863864773280788,
	0.586087235467691130294144838258730,
	0.405845151377397166906606412076961,
	0.207784955007898467600689403773245,
	0.0,
]!
const kronrod_weights = [
	f64(0.022935322010529224963732008058970),
	0.063092092629978553290700663189204,
	0.104790010322250183839876322541518,
	0.140653259715525918745189590510238,
	0.169004726639267902826583426598550,
	0.190350578064785409913256402421014,
	0.204432940075298892414161999234649,
	0.209482141084727828012999174891714,
]!
const gauss_weights = [
	f64(0.129484966168869693270611432679082),
	0.279705391489276667901467771423780,
	0.381830050505118944950369775488975,
	0.417959183673469387755102040816327,
]!

// IntegrationStatus reports why adaptive integration stopped.
pub enum IntegrationStatus {
	converged
	max_intervals
	max_evaluations
	non_finite_function_value
	non_finite_estimate
	precision_limit
}

// GaussKronrodParams configures finite-interval adaptive integration.
@[params]
pub struct GaussKronrodParams {
pub:
	a             f64
	b             f64
	abs_tol       f64 = 1e-10
	rel_tol       f64 = 1e-8
	max_intervals int = 1000
	max_evals     int = 30000
}

// ImproperGaussKronrodParams configures quadrature with finite or infinite
// bounds. Infinite endpoints must be opposite-signed for a whole-line integral.
@[params]
pub struct ImproperGaussKronrodParams {
pub:
	a             f64
	b             f64
	abs_tol       f64 = 1e-10
	rel_tol       f64 = 1e-8
	max_intervals int = 1000
	max_evals     int = 30000
}

// GaussKronrodResult contains the integral estimate and convergence diagnostics.
pub struct GaussKronrodResult {
pub:
	value          f64
	error_estimate f64
	n_calls        int
	n_intervals    int
	status         IntegrationStatus
}

struct IntervalEstimate {
	a              f64
	b              f64
	value          f64
	error_estimate f64
	status         IntegrationStatus
}

struct EvaluationState {
mut:
	calls  int
	status IntegrationStatus
}

interface IntegrationFunction {
	safe_eval(x f64) !f64
}

enum InfiniteDirection {
	positive
	negative
}

struct MappedIntegrand {
	f         func.Fn
	bound     f64
	direction InfiniteDirection
}

// adaptive_gauss_kronrod integrates a function over a finite interval using
// the embedded 7/15-point Gauss-Kronrod rule and adaptive interval subdivision.
pub fn adaptive_gauss_kronrod(f func.Fn, params GaussKronrodParams) !GaussKronrodResult {
	return adaptive_gauss_kronrod_impl(f, params)
}

// adaptive_gauss_kronrod_improper integrates over finite or infinite bounds.
// Infinite tails are mapped to [0, 1); a whole-line integral is split at zero.
pub fn adaptive_gauss_kronrod_improper(f func.Fn, params ImproperGaussKronrodParams) !GaussKronrodResult {
	if math.is_nan(params.a) || math.is_nan(params.b) || !finite_value(params.abs_tol)
		|| !finite_value(params.rel_tol) || params.abs_tol < 0.0 || params.rel_tol < 0.0
		|| (params.abs_tol == 0.0 && params.rel_tol == 0.0) || params.max_intervals < 1
		|| params.max_evals < 1 {
		return error('invalid improper Gauss-Kronrod integration parameters')
	}
	a_is_infinite := math.is_inf(params.a, 0)
	b_is_infinite := math.is_inf(params.b, 0)
	if a_is_infinite && b_is_infinite && params.a == params.b {
		return error('improper Gauss-Kronrod integration requires distinct infinite bounds')
	}
	if params.a > params.b {
		reversed := adaptive_gauss_kronrod_improper(f, ImproperGaussKronrodParams{
			a:             params.b
			b:             params.a
			abs_tol:       params.abs_tol
			rel_tol:       params.rel_tol
			max_intervals: params.max_intervals
			max_evals:     params.max_evals
		})!
		return signed_integration_result(reversed, -1.0)
	}
	if !a_is_infinite && !b_is_infinite {
		return adaptive_gauss_kronrod(f, GaussKronrodParams{
			a:             params.a
			b:             params.b
			abs_tol:       params.abs_tol
			rel_tol:       params.rel_tol
			max_intervals: params.max_intervals
			max_evals:     params.max_evals
		})
	}
	if a_is_infinite && b_is_infinite {
		if params.abs_tol == 0.0 {
			return error('whole-line improper integration requires a positive absolute tolerance')
		}
		if params.max_intervals < 2 {
			return GaussKronrodResult{
				value:          math.nan()
				error_estimate: math.nan()
				status:         .max_intervals
			}
		}
		if params.max_evals < 30 {
			return GaussKronrodResult{
				value:          math.nan()
				error_estimate: math.nan()
				status:         .max_evaluations
			}
		}
		left_intervals := params.max_intervals / 2
		left_evals := params.max_evals / 2
		half_params := GaussKronrodParams{
			a:             0.0
			b:             1.0
			abs_tol:       params.abs_tol / 2.0
			rel_tol:       0.0
			max_intervals: left_intervals
			max_evals:     left_evals
		}
		left := integrate_infinite_tail(f, 0.0, .negative, half_params)!
		if left.status != .converged {
			return left
		}
		right := integrate_infinite_tail(f, 0.0, .positive, GaussKronrodParams{
			a:             0.0
			b:             1.0
			abs_tol:       params.abs_tol / 2.0
			rel_tol:       0.0
			max_intervals: params.max_intervals - left_intervals
			max_evals:     params.max_evals - left_evals
		})!
		value := left.value + right.value
		error_estimate := left.error_estimate + right.error_estimate
		if !finite_value(value) || !finite_value(error_estimate) {
			return GaussKronrodResult{
				value:          value
				error_estimate: error_estimate
				n_calls:        left.n_calls + right.n_calls
				n_intervals:    left.n_intervals + right.n_intervals
				status:         .non_finite_estimate
			}
		}
		return GaussKronrodResult{
			value:          value
			error_estimate: error_estimate
			n_calls:        left.n_calls + right.n_calls
			n_intervals:    left.n_intervals + right.n_intervals
			status:         right.status
		}
	}
	if a_is_infinite {
		return integrate_infinite_tail(f, params.b, .negative, GaussKronrodParams{
			a:             0.0
			b:             1.0
			abs_tol:       params.abs_tol
			rel_tol:       params.rel_tol
			max_intervals: params.max_intervals
			max_evals:     params.max_evals
		})
	}
	return integrate_infinite_tail(f, params.a, .positive, GaussKronrodParams{
		a:             0.0
		b:             1.0
		abs_tol:       params.abs_tol
		rel_tol:       params.rel_tol
		max_intervals: params.max_intervals
		max_evals:     params.max_evals
	})
}

fn adaptive_gauss_kronrod_impl(f IntegrationFunction, params GaussKronrodParams) !GaussKronrodResult {
	if !finite_value(params.a) || !finite_value(params.b) || !finite_value(params.abs_tol)
		|| !finite_value(params.rel_tol) || params.abs_tol < 0.0 || params.rel_tol < 0.0
		|| (params.abs_tol == 0.0 && params.rel_tol == 0.0) || params.max_intervals < 1
		|| params.max_evals < 1 {
		return error('invalid Gauss-Kronrod integration parameters')
	}
	if params.a == params.b {
		return GaussKronrodResult{
			status: .converged
		}
	}
	sign := if params.a < params.b { 1.0 } else { -1.0 }
	a := math.min(params.a, params.b)
	b := math.max(params.a, params.b)
	mut evaluation := EvaluationState{}
	first := if params.max_evals < 15 {
		IntervalEstimate{
			value:          math.nan()
			error_estimate: math.nan()
			status:         .max_evaluations
		}
	} else {
		estimate_interval(f, a, b, mut evaluation)
	}
	if first.status != .converged {
		return GaussKronrodResult{
			value:          first.value * sign
			error_estimate: first.error_estimate
			n_calls:        evaluation.calls
			status:         first.status
		}
	}
	mut intervals := [first]
	mut total_value := first.value
	mut total_error := first.error_estimate
	for {
		tolerance := params.abs_tol + params.rel_tol * math.abs(total_value)
		if total_error <= tolerance {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         .converged
			}
		}
		if intervals.len >= params.max_intervals {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         .max_intervals
			}
		}
		mut worst_index := 0
		for i in 1 .. intervals.len {
			if intervals[i].error_estimate > intervals[worst_index].error_estimate {
				worst_index = i
			}
		}
		previous := intervals[worst_index]
		midpoint := 0.5 * previous.a + 0.5 * previous.b
		if midpoint == previous.a || midpoint == previous.b {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         .precision_limit
			}
		}
		if params.max_evals - evaluation.calls < 30 {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         .max_evaluations
			}
		}
		left := estimate_interval(f, previous.a, midpoint, mut evaluation)
		if left.status != .converged {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         left.status
			}
		}
		right := estimate_interval(f, midpoint, previous.b, mut evaluation)
		if right.status != .converged {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         right.status
			}
		}
		total_value += left.value + right.value - previous.value
		total_error = math.max(0.0, total_error + left.error_estimate + right.error_estimate -
			previous.error_estimate)
		if !finite_value(total_value) || !finite_value(total_error) {
			return GaussKronrodResult{
				value:          total_value * sign
				error_estimate: total_error
				n_calls:        evaluation.calls
				n_intervals:    intervals.len
				status:         .non_finite_estimate
			}
		}
		intervals.delete(worst_index)
		intervals << left
		intervals << right
	}
}

fn integrate_infinite_tail(f func.Fn, bound f64, direction InfiniteDirection, params GaussKronrodParams) !GaussKronrodResult {
	return adaptive_gauss_kronrod_impl(MappedIntegrand{
		f:         f
		bound:     bound
		direction: direction
	}, params)
}

fn (integrand MappedIntegrand) safe_eval(t f64) !f64 {
	remaining := 1.0 - t
	if t < 0.0 || remaining <= 0.0 {
		return error('improper integration transform received an invalid point')
	}
	distance := t / remaining
	x := if integrand.direction == .positive {
		integrand.bound + distance
	} else {
		integrand.bound - distance
	}
	jacobian := 1.0 / (remaining * remaining)
	value := integrand.f.safe_eval(x)! * jacobian
	if !finite_value(value) {
		return error('improper integration transform produced a non-finite value')
	}
	return value
}

fn signed_integration_result(result GaussKronrodResult, sign f64) GaussKronrodResult {
	return GaussKronrodResult{
		value:          result.value * sign
		error_estimate: result.error_estimate
		n_calls:        result.n_calls
		n_intervals:    result.n_intervals
		status:         result.status
	}
}

fn estimate_interval(f IntegrationFunction, a f64, b f64, mut evaluation EvaluationState) IntervalEstimate {
	center := 0.5 * a + 0.5 * b
	half_length := 0.5 * b - 0.5 * a
	f_center := sample(f, center, mut evaluation)
	if evaluation.status != .converged {
		return IntervalEstimate{
			value:          math.nan()
			error_estimate: math.nan()
			status:         evaluation.status
		}
	}
	mut kronrod_sum := kronrod_weights[7] * f_center
	mut gauss_sum := gauss_weights[3] * f_center
	mut absolute_sum := kronrod_weights[7] * math.abs(f_center)
	mut samples := [14]f64{}
	for i in 0 .. 7 {
		offset := half_length * kronrod_nodes[i]
		f_left := sample(f, center - offset, mut evaluation)
		if evaluation.status != .converged {
			return IntervalEstimate{
				value:          math.nan()
				error_estimate: math.nan()
				status:         evaluation.status
			}
		}
		samples[2 * i] = f_left
		f_right := sample(f, center + offset, mut evaluation)
		if evaluation.status != .converged {
			return IntervalEstimate{
				value:          math.nan()
				error_estimate: math.nan()
				status:         evaluation.status
			}
		}
		samples[2 * i + 1] = f_right
		kronrod_sum += kronrod_weights[i] * f_left + kronrod_weights[i] * f_right
		absolute_sum += kronrod_weights[i] * math.abs(f_left) + kronrod_weights[i] *
			math.abs(f_right)
		if i == 1 {
			gauss_sum += gauss_weights[0] * f_left + gauss_weights[0] * f_right
		} else if i == 3 {
			gauss_sum += gauss_weights[1] * f_left + gauss_weights[1] * f_right
		} else if i == 5 {
			gauss_sum += gauss_weights[2] * f_left + gauss_weights[2] * f_right
		}
	}
	value := half_length * kronrod_sum
	gauss_value := half_length * gauss_sum
	resabs := half_length * absolute_sum
	mean := 0.5 * kronrod_sum
	mut asc_sum := kronrod_weights[7] * math.abs(f_center - mean)
	for i in 0 .. 7 {
		asc_sum += kronrod_weights[i] * math.abs(samples[2 * i] - mean) +
			kronrod_weights[i] * math.abs(samples[2 * i + 1] - mean)
	}
	resasc := half_length * asc_sum
	mut error_estimate := math.abs(value - gauss_value)
	if resasc > 0.0 && error_estimate > 0.0 {
		if error_estimate < resasc / 200.0 {
			ratio := 200.0 * error_estimate / resasc
			error_estimate = resasc * math.pow(ratio, 1.5)
		} else {
			error_estimate = resasc
		}
	}
	error_estimate = math.max(error_estimate, 50.0 * prec.f64_epsilon * resabs)
	if !finite_value(value) || !finite_value(error_estimate) {
		return IntervalEstimate{
			value:          math.nan()
			error_estimate: math.nan()
			status:         .non_finite_estimate
		}
	}
	return IntervalEstimate{
		a:              a
		b:              b
		value:          value
		error_estimate: error_estimate
		status:         .converged
	}
}

fn sample(f IntegrationFunction, x f64, mut evaluation EvaluationState) f64 {
	value := f.safe_eval(x) or {
		evaluation.calls++
		evaluation.status = .non_finite_function_value
		return math.nan()
	}
	evaluation.calls++
	return value
}

fn finite_value(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}
