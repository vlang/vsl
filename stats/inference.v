module stats

import math
import vsl.fun

// Alternative selects the alternative hypothesis of a test.
pub enum Alternative {
	two_sided
	less
	greater
}

// PAdjustMethod selects the multiple-comparison correction.
pub enum PAdjustMethod {
	bonferroni
	benjamini_hochberg
}

// TTestResult holds a t statistic, its p-value, degrees of freedom, the
// estimated standard error of the difference, and the observed difference.
pub struct TTestResult {
pub:
	statistic      f64
	p_value        f64
	df             f64
	standard_error f64
	difference     f64
}

// ChiSquareResult holds a chi-square statistic, its p-value, and degrees of
// freedom.
pub struct ChiSquareResult {
pub:
	statistic f64
	p_value   f64
	df        f64
}

// ConfidenceInterval holds a two-sided estimate and its t-based bounds.
pub struct ConfidenceInterval {
pub:
	estimate   f64
	lower      f64
	upper      f64
	confidence f64
	df         f64
}

const beta_fpmin = 1e-300
const beta_eps = 3e-14
const beta_max_iter = 300

fn beta_continued_fraction(a f64, b f64, x f64) f64 {
	mut qab := a + b
	mut qap := a + 1.0
	mut qam := a - 1.0
	mut c := 1.0
	mut d := 1.0 - qab * x / qap
	if math.abs(d) < beta_fpmin {
		d = beta_fpmin
	}
	d = 1.0 / d
	mut h := d
	for m := 1; m <= beta_max_iter; m++ {
		m2 := 2 * m
		mf := f64(m)
		mut aa := mf * (b - mf) * x / ((qam + m2) * (a + m2))
		d = 1.0 + aa * d
		if math.abs(d) < beta_fpmin {
			d = beta_fpmin
		}
		c = 1.0 + aa / c
		if math.abs(c) < beta_fpmin {
			c = beta_fpmin
		}
		d = 1.0 / d
		h *= d * c
		aa = -(a + mf) * (qab + mf) * x / ((a + m2) * (qap + m2))
		d = 1.0 + aa * d
		if math.abs(d) < beta_fpmin {
			d = beta_fpmin
		}
		c = 1.0 + aa / c
		if math.abs(c) < beta_fpmin {
			c = beta_fpmin
		}
		d = 1.0 / d
		del := d * c
		h *= del
		if math.abs(del - 1.0) < beta_eps {
			break
		}
	}
	return h
}

fn beta_regularized(a f64, b f64, x f64) f64 {
	if x <= 0.0 {
		return 0.0
	}
	if x >= 1.0 {
		return 1.0
	}
	log_front := fun.log_gamma(a + b) - fun.log_gamma(a) - fun.log_gamma(b) +
		a * math.log(x) + b * math.log(1.0 - x)
	front := math.exp(log_front)
	if x < (a + 1.0) / (a + b + 2.0) {
		return front * beta_continued_fraction(a, b, x) / a
	}
	return 1.0 - front * beta_continued_fraction(b, a, 1.0 - x) / b
}

// t_upper_tail returns P(T > t) for a Student t with df degrees of freedom.
fn t_upper_tail(t f64, df f64) f64 {
	if df <= 0.0 {
		return math.nan()
	}
	x := df / (df + t * t)
	return 0.5 * beta_regularized(df * 0.5, 0.5, x)
}

fn t_critical(alpha f64, df f64) f64 {
	mut low := 0.0
	mut high := 1.0
	for t_upper_tail(high, df) > alpha && high < 1e12 {
		high *= 2.0
	}
	for _ in 0 .. 200 {
		mid := 0.5 * (low + high)
		if t_upper_tail(mid, df) > alpha {
			low = mid
		} else {
			high = mid
		}
	}
	return 0.5 * (low + high)
}

fn gamma_series(a f64, x f64) f64 {
	mut sum := 1.0 / a
	mut term := sum
	for n := 1; n <= 500; n++ {
		term *= x / (a + f64(n))
		sum += term
		if math.abs(term) < math.abs(sum) * 1e-15 {
			break
		}
	}
	return sum * math.exp(-x + a * math.log(x) - fun.log_gamma(a))
}

fn gamma_continued_fraction(a f64, x f64) f64 {
	mut b := x + 1.0 - a
	mut c := 1.0 / beta_fpmin
	mut d := 1.0 / b
	mut h := d
	for i := 1; i <= 500; i++ {
		an := -f64(i) * (f64(i) - a)
		b += 2.0
		d = an * d + b
		if math.abs(d) < beta_fpmin {
			d = beta_fpmin
		}
		c = b + an / c
		if math.abs(c) < beta_fpmin {
			c = beta_fpmin
		}
		d = 1.0 / d
		del := d * c
		h *= del
		if math.abs(del - 1.0) < 1e-15 {
			break
		}
	}
	return h
}

// gamma_upper_regularized returns Q(a, x), the upper regularized gamma.
fn gamma_upper_regularized(a f64, x f64) f64 {
	if x <= 0.0 {
		return 1.0
	}
	if x < a + 1.0 {
		return 1.0 - gamma_series(a, x)
	}
	return math.exp(-x + a * math.log(x) - fun.log_gamma(a)) * gamma_continued_fraction(a, x)
}

fn chi_square_upper_tail(x f64, df f64) f64 {
	if df <= 0.0 || x < 0.0 {
		return math.nan()
	}
	if x == 0.0 {
		return 1.0
	}
	return gamma_upper_regularized(df * 0.5, x * 0.5)
}

fn finite_value(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}

fn clamp_probability(p f64) f64 {
	if p < 0.0 {
		return 0.0
	}
	if p > 1.0 {
		return 1.0
	}
	return p
}

fn inference_sample(values []f64, name string) !Summary {
	if values.len < 2 {
		return error('${name}: sample must contain at least two observations')
	}
	summary := summarize(values, 1) or {
		return err
	}
	if summary.variance <= 0.0 || !finite_value(summary.variance) {
		return error('${name}: sample variance must be positive and finite')
	}
	return summary
}

fn t_p_value(statistic f64, df f64, alternative Alternative) f64 {
	tail := clamp_probability(t_upper_tail(math.abs(statistic), df))
	result := match alternative {
		.two_sided { 2.0 * tail }
		.greater {
			if statistic >= 0.0 {
				tail
			} else {
				1.0 - tail
			}
		}
		.less {
			if statistic <= 0.0 {
				tail
			} else {
				1.0 - tail
			}
		}
	}
	return clamp_probability(result)
}

// mean_confidence_interval returns a two-sided t confidence interval for the
// population mean. confidence must lie strictly between 0 and 1.
pub fn mean_confidence_interval(sample []f64, confidence f64) !ConfidenceInterval {
	if !finite_value(confidence) || confidence <= 0.0 || confidence >= 1.0 {
		return error('stats.mean_confidence_interval: confidence must be between 0 and 1')
	}
	summary := inference_sample(sample, 'stats.mean_confidence_interval')!
	df := f64(summary.count - 1)
	critical := t_critical(0.5 * (1.0 - confidence), df)
	standard_error := summary.stddev / math.sqrt(f64(summary.count))
	return ConfidenceInterval{
		estimate:   summary.mean
		lower:      summary.mean - critical * standard_error
		upper:      summary.mean + critical * standard_error
		confidence: confidence
		df:         df
	}
}

// t_test_one_sample tests whether the sample mean differs from mu.
pub fn t_test_one_sample(sample []f64, mu f64, alternative Alternative) !TTestResult {
	if !finite_value(mu) {
		return error('stats.t_test_one_sample: mu must be finite')
	}
	summary := inference_sample(sample, 'stats.t_test_one_sample')!
	standard_error := summary.stddev / math.sqrt(f64(summary.count))
	difference := summary.mean - mu
	statistic := difference / standard_error
	df := f64(summary.count - 1)
	return TTestResult{
		statistic:      statistic
		p_value:        t_p_value(statistic, df, alternative)
		df:             df
		standard_error: standard_error
		difference:     difference
	}
}

// t_test_paired tests the mean of after - before against zero. The slices must
// have equal lengths and contain at least two finite pairs.
pub fn t_test_paired(before []f64, after []f64, alternative Alternative) !TTestResult {
	if before.len != after.len {
		return error('stats.t_test_paired: samples must have the same length')
	}
	mut differences := []f64{cap: before.len}
	for i, value in before {
		if !finite_value(value) || !finite_value(after[i]) {
			return error('stats.t_test_paired: samples must be finite')
		}
		differences << after[i] - value
	}
	return t_test_one_sample(differences, 0.0, alternative)
}

// t_test_independent compares two independent samples. With equal_var true it
// uses the pooled-variance Student test; otherwise it uses Welch's test.
pub fn t_test_independent(a []f64, b []f64, equal_var bool, alternative Alternative) !TTestResult {
	left := inference_sample(a, 'stats.t_test_independent')!
	right := inference_sample(b, 'stats.t_test_independent')!
	na := f64(left.count)
	nb := f64(right.count)
	va_over_na := left.variance / na
	vb_over_nb := right.variance / nb
	mut standard_error := 0.0
	mut df := 0.0
	if equal_var {
		pooled := ((na - 1.0) * left.variance + (nb - 1.0) * right.variance) / (na + nb - 2.0)
		standard_error = math.sqrt(pooled * (1.0 / na + 1.0 / nb))
		df = na + nb - 2.0
	} else {
		standard_error = math.sqrt(va_over_na + vb_over_nb)
		denominator := (va_over_na * va_over_na) / (na - 1.0) +
			(vb_over_nb * vb_over_nb) / (nb - 1.0)
		if denominator <= 0.0 {
			return error('stats.t_test_independent: Welch degrees of freedom are undefined')
		}
		df = (va_over_na + vb_over_nb) * (va_over_na + vb_over_nb) / denominator
	}
	if !finite_value(standard_error) || standard_error <= 0.0 || !finite_value(df) || df <= 0.0 {
		return error('stats.t_test_independent: test statistics are not finite')
	}
	difference := left.mean - right.mean
	statistic := difference / standard_error
	return TTestResult{
		statistic:      statistic
		p_value:        t_p_value(statistic, df, alternative)
		df:             df
		standard_error: standard_error
		difference:     difference
	}
}

// chi_square_goodness_of_fit compares observed counts with expected counts.
// Expected counts must be positive; degrees of freedom are len(observed) - 1.
pub fn chi_square_goodness_of_fit(observed []f64, expected []f64) !ChiSquareResult {
	if observed.len != expected.len || observed.len < 2 {
		return error('stats.chi_square_goodness_of_fit: samples must have equal length of at least two')
	}
	mut statistic := 0.0
	for i, count in observed {
		target := expected[i]
		if !finite_value(count) || !finite_value(target) || count < 0.0 || target <= 0.0 {
			return error('stats.chi_square_goodness_of_fit: counts must be finite and non-negative, expected counts positive')
		}
		delta := count - target
		statistic += delta * delta / target
	}
	if !finite_value(statistic) {
		return error('stats.chi_square_goodness_of_fit: statistic overflowed f64')
	}
	df := f64(observed.len - 1)
	return ChiSquareResult{
		statistic: statistic
		p_value:   clamp_probability(chi_square_upper_tail(statistic, df))
		df:        df
	}
}

// chi_square_independence tests rows against columns of a contingency table.
// Every expected count must be positive.
pub fn chi_square_independence(table [][]f64) !ChiSquareResult {
	rows := table.len
	if rows < 2 || table[0].len < 2 {
		return error('stats.chi_square_independence: table must be at least 2x2')
	}
	cols := table[0].len
	mut row_sums := []f64{len: rows}
	mut col_sums := []f64{len: cols}
	mut total := 0.0
	for i, row in table {
		if row.len != cols {
			return error('stats.chi_square_independence: rows must have equal length')
		}
		for j, count in row {
			if !finite_value(count) || count < 0.0 {
				return error('stats.chi_square_independence: counts must be finite and non-negative')
			}
			row_sums[i] += count
			col_sums[j] += count
			total += count
		}
	}
	if !finite_value(total) || total <= 0.0 {
		return error('stats.chi_square_independence: total count must be positive and finite')
	}
	mut statistic := 0.0
	for i, row in table {
		for j, count in row {
			expected := row_sums[i] * col_sums[j] / total
			if expected <= 0.0 {
				return error('stats.chi_square_independence: expected counts must be positive')
			}
			delta := count - expected
			statistic += delta * delta / expected
		}
	}
	if !finite_value(statistic) {
		return error('stats.chi_square_independence: statistic overflowed f64')
	}
	df := f64((rows - 1) * (cols - 1))
	return ChiSquareResult{
		statistic: statistic
		p_value:   clamp_probability(chi_square_upper_tail(statistic, df))
		df:        df
	}
}

struct IndexedP {
	value f64
	index int
}

fn compare_indexed_p(a &IndexedP, b &IndexedP) int {
	if a.value < b.value {
		return -1
	}
	if a.value > b.value {
		return 1
	}
	return 0
}

// adjust_p_values corrects a slice of p-values for multiple comparisons.
// Bonferroni multiplies by the number of tests; Benjamini-Hochberg uses the
// step-up procedure and preserves monotonicity after capping at one.
pub fn adjust_p_values(pvalues []f64, method PAdjustMethod) ![]f64 {
	if pvalues.len == 0 {
		return error('stats.adjust_p_values: p-values must not be empty')
	}
	for p in pvalues {
		if !finite_value(p) || p < 0.0 || p > 1.0 {
			return error('stats.adjust_p_values: p-values must be finite and between 0 and 1')
		}
	}
	m := f64(pvalues.len)
	if method == .bonferroni {
		mut adjusted := []f64{len: pvalues.len}
		for i, p in pvalues {
			adjusted[i] = clamp_probability(p * m)
		}
		return adjusted
	}
	mut items := []IndexedP{cap: pvalues.len}
	for i, p in pvalues {
		items << IndexedP{p, i}
	}
	items.sort_with_compare(compare_indexed_p)
	mut adjusted := []f64{len: pvalues.len}
	mut running := 1.0
	for i := pvalues.len - 1; i >= 0; i-- {
		candidate := m / f64(i + 1) * items[i].value
		if candidate < running {
			running = candidate
		}
		adjusted[items[i].index] = clamp_probability(running)
	}
	return adjusted
}
