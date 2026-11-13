module integrate

import math
import vsl.func
import vsl.internal.prec

const kronrod_nodes = [
	0.991455371120812639206854697526329,
	0.949107912342758524526189684047851,
	0.864864423359769072789712788640926,
	0.741531185599394439863864773280788,
	0.586087235467691130294144838258730,
	0.405845151377397166906606412076961,
	0.207784955007898467600689403773245,
	0.0,
]
const kronrod_weights = [
	0.022935322010529224963732008058970,
	0.063092092629978553290700663189204,
	0.104790010322250183839876322541518,
	0.140653259715525918745189590510238,
	0.169004726639267902826583426598550,
	0.190350578064785409913256402421014,
	0.204432940075298892414161999234649,
	0.209482141084727828012999174891714,
]
const gauss_weights = [
	0.129484966168869693270611432679082,
	0.279705391489276667901467771423780,
	0.381830050505118944950369775488975,
	0.417959183673469387755102040816327,
]

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

// adaptive_gauss_kronrod integrates a function over a finite interval using
// the embedded 7/15-point Gauss-Kronrod rule and adaptive interval subdivision.
pub fn adaptive_gauss_kronrod(f func.Fn, params GaussKronrodParams) !GaussKronrodResult {
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

fn estimate_interval(f func.Fn, a f64, b f64, mut evaluation EvaluationState) IntervalEstimate {
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

fn sample(f func.Fn, x f64, mut evaluation EvaluationState) f64 {
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
