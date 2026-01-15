module la

import math

// correlation_matrix computes the Pearson correlation matrix for a data matrix.
// Input:
//   data -- m x n matrix where rows are samples and columns are features
// Output:
//   corr -- n x n correlation matrix
pub fn correlation_matrix(data &Matrix[f64]) &Matrix[f64] {
	m := data.m // number of samples
	n := data.n // number of features

	// Compute means for each feature
	mut means := []f64{len: n}
	for j in 0 .. n {
		mut sum := 0.0
		for i in 0 .. m {
			sum += data.get(i, j)
		}
		means[j] = sum / f64(m)
	}

	// Compute standard deviations for each feature
	mut stds := []f64{len: n}
	for j in 0 .. n {
		mut sum_sq := 0.0
		for i in 0 .. m {
			diff := data.get(i, j) - means[j]
			sum_sq += diff * diff
		}
		stds[j] = math.sqrt(sum_sq / f64(m))
		if stds[j] == 0 {
			stds[j] = 1.0 // Avoid division by zero for constant features
		}
	}

	// Compute correlation matrix
	mut corr := Matrix.new[f64](n, n)

	for i in 0 .. n {
		for j in 0 .. n {
			if i == j {
				corr.set(i, j, 1.0) // Diagonal is always 1
			} else if j > i {
				// Compute correlation between features i and j
				mut sum := 0.0
				for k in 0 .. m {
					xi := (data.get(k, i) - means[i]) / stds[i]
					xj := (data.get(k, j) - means[j]) / stds[j]
					sum += xi * xj
				}
				r := sum / f64(m)
				corr.set(i, j, r)
				corr.set(j, i, r) // Symmetric
			}
		}
	}

	return corr
}

// covariance_matrix computes the covariance matrix for a data matrix.
// Input:
//   data -- m x n matrix where rows are samples and columns are features
//   ddof -- delta degrees of freedom (0 for population, 1 for sample)
// Output:
//   cov -- n x n covariance matrix
pub fn covariance_matrix(data &Matrix[f64], ddof int) &Matrix[f64] {
	m := data.m // number of samples
	n := data.n // number of features

	// Compute means for each feature
	mut means := []f64{len: n}
	for j in 0 .. n {
		mut sum := 0.0
		for i in 0 .. m {
			sum += data.get(i, j)
		}
		means[j] = sum / f64(m)
	}

	// Compute covariance matrix
	mut cov := Matrix.new[f64](n, n)
	divisor := f64(m - ddof)

	for i in 0 .. n {
		for j in i .. n {
			mut sum := 0.0
			for k in 0 .. m {
				di := data.get(k, i) - means[i]
				dj := data.get(k, j) - means[j]
				sum += di * dj
			}
			c := sum / divisor
			cov.set(i, j, c)
			if i != j {
				cov.set(j, i, c) // Symmetric
			}
		}
	}

	return cov
}

// column_mean computes the mean of each column in a matrix
pub fn column_mean(data &Matrix[f64]) []f64 {
	m := data.m
	n := data.n

	mut means := []f64{len: n}
	for j in 0 .. n {
		mut sum := 0.0
		for i in 0 .. m {
			sum += data.get(i, j)
		}
		means[j] = sum / f64(m)
	}

	return means
}

// column_std computes the standard deviation of each column in a matrix
pub fn column_std(data &Matrix[f64], ddof int) []f64 {
	m := data.m
	n := data.n
	means := column_mean(data)

	mut stds := []f64{len: n}
	divisor := f64(m - ddof)

	for j in 0 .. n {
		mut sum_sq := 0.0
		for i in 0 .. m {
			diff := data.get(i, j) - means[j]
			sum_sq += diff * diff
		}
		stds[j] = math.sqrt(sum_sq / divisor)
	}

	return stds
}

// column_min computes the minimum of each column in a matrix
pub fn column_min(data &Matrix[f64]) []f64 {
	m := data.m
	n := data.n

	mut mins := []f64{len: n, init: math.max_f64}
	for j in 0 .. n {
		for i in 0 .. m {
			val := data.get(i, j)
			if val < mins[j] {
				mins[j] = val
			}
		}
	}

	return mins
}

// column_max computes the maximum of each column in a matrix
pub fn column_max(data &Matrix[f64]) []f64 {
	m := data.m
	n := data.n

	mut maxs := []f64{len: n, init: -math.max_f64}
	for j in 0 .. n {
		for i in 0 .. m {
			val := data.get(i, j)
			if val > maxs[j] {
				maxs[j] = val
			}
		}
	}

	return maxs
}

// column_sum computes the sum of each column in a matrix
pub fn column_sum(data &Matrix[f64]) []f64 {
	m := data.m
	n := data.n

	mut sums := []f64{len: n}
	for j in 0 .. n {
		for i in 0 .. m {
			sums[j] += data.get(i, j)
		}
	}

	return sums
}

// center_matrix centers each column by subtracting its mean
pub fn center_matrix(data &Matrix[f64]) &Matrix[f64] {
	m := data.m
	n := data.n
	means := column_mean(data)

	mut centered := Matrix.new[f64](m, n)
	for i in 0 .. m {
		for j in 0 .. n {
			centered.set(i, j, data.get(i, j) - means[j])
		}
	}

	return centered
}

// standardize_matrix standardizes each column (z-score)
pub fn standardize_matrix(data &Matrix[f64]) &Matrix[f64] {
	m := data.m
	n := data.n
	means := column_mean(data)
	stds := column_std(data, 0)

	mut standardized := Matrix.new[f64](m, n)
	for i in 0 .. m {
		for j in 0 .. n {
			std := if stds[j] == 0 { 1.0 } else { stds[j] }
			standardized.set(i, j, (data.get(i, j) - means[j]) / std)
		}
	}

	return standardized
}
