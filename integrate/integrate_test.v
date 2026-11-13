module integrate

import math
import vsl.func

fn test_integrate_polynomial_and_report_error_estimate() {
	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return x * x * x * x
		}
	)
	result := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a:       -1.0
		b:       2.0
		abs_tol: 1e-11
		rel_tol: 1e-11
	})!
	assert result.status == .converged
	assert math.abs(result.value - 6.6) <= 1e-12
	assert result.error_estimate <= 1e-11 + 1e-11 * math.abs(result.value)
	assert result.n_calls == 15
	assert result.n_intervals == 1
}

fn test_integrate_oscillatory_function_adaptively() {
	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return math.sin(20.0 * x)
		}
	)
	result := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a:       0.0
		b:       1.0
		abs_tol: 1e-10
		rel_tol: 1e-10
	})!
	expected := (1.0 - math.cos(20.0)) / 20.0
	assert result.status == .converged
	assert math.abs(result.value - expected) <= 1e-10
	assert result.n_intervals > 1
	assert result.n_calls <= 30000
}

fn test_integrate_reversed_and_zero_width_intervals() {
	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return x * x
		}
	)
	forward := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a: 0.0
		b: 1.0
	})!
	reversed := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a: 1.0
		b: 0.0
	})!
	assert math.abs(forward.value - 1.0 / 3.0) <= 1e-12
	assert math.abs(reversed.value + forward.value) <= 1e-15
	assert reversed.error_estimate == forward.error_estimate

	zero := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a: 2.0
		b: 2.0
	})!
	assert zero.status == .converged
	assert zero.value == 0.0
	assert zero.error_estimate == 0.0
	assert zero.n_calls == 0
}

fn test_integrate_reports_non_finite_callbacks_and_limits() {
	nan_function := func.Fn.new(
		f: fn (_ f64, _ []f64) f64 {
			return math.nan()
		}
	)
	nan_result := adaptive_gauss_kronrod(nan_function, GaussKronrodParams{
		a: 0.0
		b: 1.0
	})!
	assert nan_result.status == .non_finite_function_value
	assert nan_result.n_calls == 1
	assert nan_result.n_intervals == 0

	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return math.exp(x)
		}
	)
	evaluation_limited := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a:         0.0
		b:         1.0
		abs_tol:   1e-30
		rel_tol:   1e-30
		max_evals: 15
	})!
	assert evaluation_limited.status == .max_evaluations
	assert evaluation_limited.n_calls == 15

	interval_limited := adaptive_gauss_kronrod(f, GaussKronrodParams{
		a:             0.0
		b:             1.0
		abs_tol:       1e-30
		rel_tol:       1e-30
		max_intervals: 1
	})!
	assert interval_limited.status == .max_intervals
	assert interval_limited.n_intervals == 1
}

fn test_integrate_reports_non_finite_estimates_and_precision_limits() {
	large_function := func.Fn.new(
		f: fn (_ f64, _ []f64) f64 {
			return 1e308
		}
	)
	overflowed := adaptive_gauss_kronrod(large_function, GaussKronrodParams{
		a: 0.0
		b: 10.0
	})!
	assert overflowed.status == .non_finite_estimate
	assert overflowed.n_calls == 15

	constant := func.Fn.new(
		f: fn (_ f64, _ []f64) f64 {
			return 1.0
		}
	)
	precision_limited := adaptive_gauss_kronrod(constant, GaussKronrodParams{
		a:       1.0
		b:       1.0000000000000002
		abs_tol: 1e-30
		rel_tol: 0.0
	})!
	assert precision_limited.status == .precision_limit
	assert precision_limited.n_intervals == 1
}

fn test_integrate_rejects_invalid_parameters() {
	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return x
		}
	)
	adaptive_gauss_kronrod(f, GaussKronrodParams{
		a:       1.0
		b:       0.0
		abs_tol: -1.0
	}) or {
		assert err.msg().contains('invalid Gauss-Kronrod')
		return
	}
	assert false, 'expected invalid integration parameters to return an error'
}
