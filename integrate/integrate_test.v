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

fn test_integrate_improper_one_sided_exponential_tails() {
	positive_tail := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return math.exp(-x)
		}
	)
	right := adaptive_gauss_kronrod_improper(positive_tail, ImproperGaussKronrodParams{
		a:       0.0
		b:       math.inf(1)
		abs_tol: 1e-9
		rel_tol: 1e-9
	})!
	assert right.status == .converged
	assert math.abs(right.value - 1.0) < 1e-8
	assert right.error_estimate <= 1e-9 + 1e-9 * math.abs(right.value)

	negative_tail := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return math.exp(x)
		}
	)
	left := adaptive_gauss_kronrod_improper(negative_tail, ImproperGaussKronrodParams{
		a:       math.inf(-1)
		b:       0.0
		abs_tol: 1e-9
		rel_tol: 1e-9
	})!
	assert left.status == .converged
	assert math.abs(left.value - 1.0) < 1e-8

	reversed := adaptive_gauss_kronrod_improper(positive_tail, ImproperGaussKronrodParams{
		a:       math.inf(1)
		b:       0.0
		abs_tol: 1e-9
		rel_tol: 1e-9
	})!
	assert reversed.status == .converged
	assert math.abs(reversed.value + 1.0) < 1e-8
}

fn test_integrate_improper_whole_line_and_finite_bounds() {
	rational := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return 1.0 / (1.0 + x * x)
		}
	)
	whole_line := adaptive_gauss_kronrod_improper(rational, ImproperGaussKronrodParams{
		a:       math.inf(-1)
		b:       math.inf(1)
		abs_tol: 1e-9
		rel_tol: 1e-9
	})!
	assert whole_line.status == .converged
	assert math.abs(whole_line.value - math.acos(-1.0)) < 1e-8
	assert whole_line.error_estimate <= 1e-9 + 1e-9 * math.abs(whole_line.value)
	assert whole_line.n_calls >= 30

	reversed := adaptive_gauss_kronrod_improper(rational, ImproperGaussKronrodParams{
		a:       math.inf(1)
		b:       math.inf(-1)
		abs_tol: 1e-9
		rel_tol: 1e-9
	})!
	assert reversed.status == .converged
	assert math.abs(reversed.value + whole_line.value) < 1e-12

	polynomial := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return x * x
		}
	)
	finite := adaptive_gauss_kronrod_improper(polynomial, ImproperGaussKronrodParams{
		a: 0.0
		b: 1.0
	})!
	assert finite.status == .converged
	assert math.abs(finite.value - 1.0 / 3.0) < 1e-12
}

fn test_integrate_improper_validates_bounds_and_whole_line_budget() {
	f := func.Fn.new(
		f: fn (x f64, _ []f64) f64 {
			return math.exp(-x * x)
		}
	)
	if _ := adaptive_gauss_kronrod_improper(f, ImproperGaussKronrodParams{
		a: math.inf(1)
		b: math.inf(1)
	}) {
		assert false, 'equal infinite bounds must be rejected'
	}
	if _ := adaptive_gauss_kronrod_improper(f, ImproperGaussKronrodParams{
		a:       math.inf(-1)
		b:       math.inf(1)
		abs_tol: 0.0
		rel_tol: 1e-8
	}) {
		assert false, 'whole-line integration requires a positive absolute tolerance'
	}
	limited := adaptive_gauss_kronrod_improper(f, ImproperGaussKronrodParams{
		a:             math.inf(-1)
		b:             math.inf(1)
		abs_tol:       1e-8
		max_intervals: 1
	})!
	assert limited.status == .max_intervals

	evaluation_limited := adaptive_gauss_kronrod_improper(f, ImproperGaussKronrodParams{
		a:         math.inf(-1)
		b:         math.inf(1)
		abs_tol:   1e-8
		max_evals: 29
	})!
	assert evaluation_limited.status == .max_evaluations

	non_finite := func.Fn.new(
		f: fn (_ f64, _ []f64) f64 {
			return math.inf(1)
		}
	)
	non_finite_result := adaptive_gauss_kronrod_improper(non_finite,
		ImproperGaussKronrodParams{
			a:       0.0
			b:       math.inf(1)
			abs_tol: 1e-8
		})!
	assert non_finite_result.status == .non_finite_function_value
	assert non_finite_result.n_calls == 1
}
