module stats

import math

const inference_a = [f64(2.0), 4.0, 6.0, 8.0, 10.0]
const inference_b = [f64(3.0), 5.0, 7.0, 9.0, 11.0]

fn test_mean_confidence_interval_matches_t_critical() {
	interval := mean_confidence_interval(inference_a, 0.95)!
	assert math.abs(interval.estimate - 6.0) < 1e-12
	assert math.abs(interval.df - 4.0) < 1e-12
	assert math.abs(interval.lower - 2.0735177) < 1e-4
	assert math.abs(interval.upper - 9.9264823) < 1e-4
	assert interval.lower < interval.estimate && interval.estimate < interval.upper
}

fn test_t_test_one_sample_matches_reference() {
	result := t_test_one_sample(inference_a, 5.0, .two_sided)!
	assert math.abs(result.statistic - 0.7071067811865475) < 1e-10
	assert math.abs(result.df - 4.0) < 1e-12
	assert math.abs(result.difference - 1.0) < 1e-12
	// t = 1/sqrt(2) with df = 4 has the exact two-sided p-value 14/27.
	assert math.abs(result.p_value - 14.0 / 27.0) < 1e-12
}

fn test_t_test_one_sample_sidedness() {
	greater := t_test_one_sample(inference_a, 5.0, .greater)!
	less := t_test_one_sample(inference_a, 5.0, .less)!
	two_sided := t_test_one_sample(inference_a, 5.0, .two_sided)!
	assert math.abs(greater.p_value - two_sided.p_value / 2.0) < 1e-12
	assert math.abs(less.p_value - (1.0 - two_sided.p_value / 2.0)) < 1e-12
	assert less.p_value > 0.7
}

fn test_t_test_paired_matches_reference() {
	before := [f64(1.0), 2.0, 3.0, 4.0, 5.0]
	after := [f64(2.0), 4.0, 5.0, 8.0, 10.0]
	result := t_test_paired(before, after, .two_sided)!
	assert math.abs(result.statistic - 3.810317377662721) < 1e-10
	assert math.abs(result.df - 4.0) < 1e-12
	assert math.abs(result.difference - 2.8) < 1e-12
	assert math.abs(result.p_value - 0.01893999467345647) < 1e-4
}

fn test_t_test_independent_welch_matches_reference() {
	result := t_test_independent([f64(1.0), 2.0, 3.0, 4.0, 5.0], inference_b, false, .two_sided)!
	assert math.abs(result.statistic + 2.5298221281347035) < 1e-10
	assert math.abs(result.df - 5.882352941176471) < 1e-9
	assert math.abs(result.p_value - 0.04546461860237682) < 1e-6
}

fn test_t_test_independent_pooled_matches_reference() {
	result := t_test_independent([f64(1.0), 2.0, 3.0, 4.0, 5.0], inference_b, true, .two_sided)!
	assert math.abs(result.statistic + 2.5298221281347035) < 1e-10
	assert math.abs(result.df - 8.0) < 1e-12
	assert math.abs(result.p_value - 0.03526520347442166) < 1e-4
}

fn test_chi_square_goodness_of_fit_matches_reference() {
	result := chi_square_goodness_of_fit([10.0, 20.0, 30.0], [20.0, 20.0, 20.0])!
	assert math.abs(result.statistic - 10.0) < 1e-12
	assert math.abs(result.df - 2.0) < 1e-12
	assert math.abs(result.p_value - 0.006737946999085467) < 1e-12
}

fn test_chi_square_independence_matches_reference() {
	table := [[f64(10.0), 20.0], [20.0, 10.0]]
	result := chi_square_independence(table)!
	assert math.abs(result.statistic - 6.666666666666667) < 1e-10
	assert math.abs(result.df - 1.0) < 1e-12
	assert math.abs(result.p_value - 0.009823274507519242) < 1e-10
}

fn test_adjust_p_values_methods() {
	pvalues := [f64(0.01), 0.02, 0.03, 0.04, 0.05]
	bonferroni := adjust_p_values(pvalues, .bonferroni)!
	assert bonferroni == [f64(0.05), 0.1, 0.15, 0.2, 0.25]
	bh := adjust_p_values(pvalues, .benjamini_hochberg)!
	assert bh == [f64(0.05), 0.05, 0.05, 0.05, 0.05]
	assert pvalues == [f64(0.01), 0.02, 0.03, 0.04, 0.05]
}

fn test_adjust_p_values_bh_preserves_order_with_unsorted_input() {
	adjusted := adjust_p_values([f64(0.03), 0.01, 0.05], .benjamini_hochberg)!
	assert math.abs(adjusted[0] - 0.045) < 1e-12
	assert math.abs(adjusted[1] - 0.03) < 1e-12
	assert math.abs(adjusted[2] - 0.05) < 1e-12
}

fn test_inference_rejects_invalid_samples() {
	mean_confidence_interval([1.0], 0.95) or {
		return
	}
	assert false, 'expected a single observation to be rejected'
	t_test_one_sample([f64(math.nan())], 0.0, .two_sided) or {
		return
	}
	assert false, 'expected non-finite samples to be rejected'
	t_test_independent(inference_a, [2.0], false, .two_sided) or {
		return
	}
	assert false, 'expected a short independent sample to be rejected'
}

fn test_inference_rejects_invalid_parameters() {
	mean_confidence_interval(inference_a, 1.0) or {
		return
	}
	assert false, 'expected confidence of one to be rejected'
	t_test_paired([f64(1.0), 2.0], [1.0], .two_sided) or {
		return
	}
	assert false, 'expected mismatched paired lengths to be rejected'
}

fn test_chi_square_rejects_invalid_inputs() {
	chi_square_goodness_of_fit([10.0, 20.0], [20.0, 0.0]) or {
		return
	}
	assert false, 'expected a zero expected count to be rejected'
	chi_square_independence([[1.0, 2.0], [3.0]]) or {
		return
	}
	assert false, 'expected a ragged table to be rejected'
	adjust_p_values([f64(1.5)], .bonferroni) or {
		return
	}
	assert false, 'expected out-of-range p-values to be rejected'
}
