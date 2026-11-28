module main

import vsl.stats

fn main() {
	sample := [f64(2.0), 4.0, 6.0, 8.0, 10.0]
	interval := stats.mean_confidence_interval(sample, 0.95) or {
		eprintln('confidence interval failed: ${err}')
		return
	}
	println('95% CI for the mean: [${interval.lower}, ${interval.upper}]')

	one := stats.t_test_one_sample(sample, 5.0, .two_sided) or {
		eprintln('one-sample t-test failed: ${err}')
		return
	}
	println('one-sample: t=${one.statistic}, df=${one.df}, p=${one.p_value}')

	welch := stats.t_test_independent([f64(1.0), 2.0, 3.0, 4.0, 5.0],
		[3.0, 5.0, 7.0, 9.0, 11.0], false, .two_sided) or {
		eprintln('Welch t-test failed: ${err}')
		return
	}
	println('Welch: t=${welch.statistic}, df=${welch.df}, p=${welch.p_value}')

	gof := stats.chi_square_goodness_of_fit([10.0, 20.0, 30.0], [20.0, 20.0, 20.0]) or {
		eprintln('goodness-of-fit failed: ${err}')
		return
	}
	println('goodness-of-fit: chi2=${gof.statistic}, df=${gof.df}, p=${gof.p_value}')

	adjusted := stats.adjust_p_values([f64(0.01), 0.02, 0.03, 0.04, 0.05],
		.benjamini_hochberg) or {
		eprintln('p-value adjustment failed: ${err}')
		return
	}
	println('Benjamini-Hochberg adjusted p-values: ${adjusted}')
}
