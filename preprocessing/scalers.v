module preprocessing

import math
import vsl.errors

// StandardScaler standardizes features by removing the mean and scaling to unit variance.
// Formula: z = (x - mean) / std
@[heap]
pub struct StandardScaler {
mut:
	fitted bool
pub mut:
	mean_      []f64 // mean of each feature
	std_       []f64 // standard deviation of each feature
	n_features int
}

// StandardScaler.new creates a new StandardScaler
pub fn StandardScaler.new() &StandardScaler {
	return &StandardScaler{}
}

// fit computes the mean and std to be used for later scaling
pub fn (mut s StandardScaler) fit(x [][]f64) ! {
	if x.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	n_samples := x.len
	s.n_features = x[0].len
	s.mean_ = []f64{len: s.n_features}
	s.std_ = []f64{len: s.n_features}

	// Compute mean
	for j in 0 .. s.n_features {
		mut sum := 0.0
		for i in 0 .. n_samples {
			sum += x[i][j]
		}
		s.mean_[j] = sum / f64(n_samples)
	}

	// Compute standard deviation
	for j in 0 .. s.n_features {
		mut sum_sq := 0.0
		for i in 0 .. n_samples {
			diff := x[i][j] - s.mean_[j]
			sum_sq += diff * diff
		}
		s.std_[j] = math.sqrt(sum_sq / f64(n_samples))
		// Avoid division by zero
		if s.std_[j] == 0 {
			s.std_[j] = 1.0
		}
	}

	s.fitted = true
}

// transform applies the standardization to the data
pub fn (s &StandardScaler) transform(x [][]f64) ![][]f64 {
	if !s.fitted {
		return errors.error('StandardScaler must be fitted before transform', .efailed)
	}

	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: s.n_features}
		for j in 0 .. s.n_features {
			row[j] = (x[i][j] - s.mean_[j]) / s.std_[j]
		}
		result[i] = row
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut s StandardScaler) fit_transform(x [][]f64) ![][]f64 {
	s.fit(x)!
	return s.transform(x)
}

// inverse_transform reverses the standardization
pub fn (s &StandardScaler) inverse_transform(x [][]f64) ![][]f64 {
	if !s.fitted {
		return errors.error('StandardScaler must be fitted before inverse_transform',
			.efailed)
	}

	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: s.n_features}
		for j in 0 .. s.n_features {
			row[j] = x[i][j] * s.std_[j] + s.mean_[j]
		}
		result[i] = row
	}
	return result
}

// MinMaxScaler transforms features by scaling each feature to a given range.
// Formula: x_scaled = (x - min) / (max - min) * (feature_max - feature_min) + feature_min
@[heap]
pub struct MinMaxScaler {
mut:
	fitted bool
pub mut:
	min_        []f64 // minimum of each feature
	max_        []f64 // maximum of each feature
	data_range_ []f64 // max - min for each feature
	n_features  int
	feature_min f64 = 0.0 // desired minimum of transformed feature
	feature_max f64 = 1.0 // desired maximum of transformed feature
}

// MinMaxScaler.new creates a new MinMaxScaler with optional range
pub fn MinMaxScaler.new(feature_min f64, feature_max f64) &MinMaxScaler {
	return &MinMaxScaler{
		feature_min: feature_min
		feature_max: feature_max
	}
}

// fit computes the min and max to be used for later scaling
pub fn (mut s MinMaxScaler) fit(x [][]f64) ! {
	if x.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	n_samples := x.len
	s.n_features = x[0].len
	s.min_ = []f64{len: s.n_features, init: math.max_f64}
	s.max_ = []f64{len: s.n_features, init: -math.max_f64}
	s.data_range_ = []f64{len: s.n_features}

	// Compute min and max
	for j in 0 .. s.n_features {
		for i in 0 .. n_samples {
			if x[i][j] < s.min_[j] {
				s.min_[j] = x[i][j]
			}
			if x[i][j] > s.max_[j] {
				s.max_[j] = x[i][j]
			}
		}
		s.data_range_[j] = s.max_[j] - s.min_[j]
		// Avoid division by zero
		if s.data_range_[j] == 0 {
			s.data_range_[j] = 1.0
		}
	}

	s.fitted = true
}

// transform applies the min-max scaling to the data
pub fn (s &MinMaxScaler) transform(x [][]f64) ![][]f64 {
	if !s.fitted {
		return errors.error('MinMaxScaler must be fitted before transform', .efailed)
	}

	feature_range := s.feature_max - s.feature_min
	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: s.n_features}
		for j in 0 .. s.n_features {
			scaled := (x[i][j] - s.min_[j]) / s.data_range_[j]
			row[j] = scaled * feature_range + s.feature_min
		}
		result[i] = row
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut s MinMaxScaler) fit_transform(x [][]f64) ![][]f64 {
	s.fit(x)!
	return s.transform(x)
}

// inverse_transform reverses the min-max scaling
pub fn (s &MinMaxScaler) inverse_transform(x [][]f64) ![][]f64 {
	if !s.fitted {
		return errors.error('MinMaxScaler must be fitted before inverse_transform', .efailed)
	}

	feature_range := s.feature_max - s.feature_min
	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: s.n_features}
		for j in 0 .. s.n_features {
			unscaled := (x[i][j] - s.feature_min) / feature_range
			row[j] = unscaled * s.data_range_[j] + s.min_[j]
		}
		result[i] = row
	}
	return result
}

// RobustScaler scales features using statistics that are robust to outliers.
// Uses median and interquartile range (IQR) instead of mean and std.
@[heap]
pub struct RobustScaler {
mut:
	fitted bool
pub mut:
	median_    []f64 // median of each feature
	iqr_       []f64 // interquartile range of each feature
	n_features int
}

// RobustScaler.new creates a new RobustScaler
pub fn RobustScaler.new() &RobustScaler {
	return &RobustScaler{}
}

// fit computes the median and IQR to be used for later scaling
pub fn (mut s RobustScaler) fit(x [][]f64) ! {
	if x.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	n_samples := x.len
	s.n_features = x[0].len
	s.median_ = []f64{len: s.n_features}
	s.iqr_ = []f64{len: s.n_features}

	for j in 0 .. s.n_features {
		// Extract column and sort
		mut col := []f64{len: n_samples}
		for i in 0 .. n_samples {
			col[i] = x[i][j]
		}
		col.sort(a < b)

		// Compute median
		if n_samples % 2 == 0 {
			s.median_[j] = (col[n_samples / 2 - 1] + col[n_samples / 2]) / 2.0
		} else {
			s.median_[j] = col[n_samples / 2]
		}

		// Compute IQR (Q3 - Q1)
		q1_idx := n_samples / 4
		q3_idx := 3 * n_samples / 4
		q1 := col[q1_idx]
		q3 := col[q3_idx]
		s.iqr_[j] = q3 - q1

		// Avoid division by zero
		if s.iqr_[j] == 0 {
			s.iqr_[j] = 1.0
		}
	}

	s.fitted = true
}

// transform applies the robust scaling to the data
pub fn (s &RobustScaler) transform(x [][]f64) ![][]f64 {
	if !s.fitted {
		return errors.error('RobustScaler must be fitted before transform', .efailed)
	}

	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: s.n_features}
		for j in 0 .. s.n_features {
			row[j] = (x[i][j] - s.median_[j]) / s.iqr_[j]
		}
		result[i] = row
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut s RobustScaler) fit_transform(x [][]f64) ![][]f64 {
	s.fit(x)!
	return s.transform(x)
}
