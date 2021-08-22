import vsl.easings
import math

// Linear tests
fn test_linear_interpolation() {
	assert compare(easings.linear_interpolation(2), 2.0)
}

// Quadratic tests
fn test_quadratic_ease_in() {
	assert compare(easings.quadratic_ease_in(2), 4.0)
}

fn test_quadratic_ease_out() {
	assert compare(easings.quadratic_ease_out(5), -15.0)
}

fn test_quadratic_ease_in_out() {
	// p < 0.5
	assert compare(easings.quadratic_ease_in_out(0.4), 0.32)
	// p >= 0.5
	assert compare(easings.quadratic_ease_in_out(0.6), 0.68)
}

// Cubic tests
fn test_cubic_ease_in() {
	assert compare(easings.cubic_ease_in(3), 27.0)
}

fn test_cubic_ease_out() {
	assert compare(easings.cubic_ease_out(4), 28.0)
}

fn test_cubic_ease_in_out() {
	// p < 0.5
	assert compare(easings.cubic_ease_in_out(0.4), 0.256)
	// p >= 0.5
	assert compare(easings.cubic_ease_in_out(0.6), 0.744)
}

// Quadratic tests
fn test_quartic_ease_in() {
	assert compare(easings.quartic_ease_in(3), 81.0)
}

fn test_quartic_ease_out() {
	assert compare(easings.quartic_ease_out(3), -15.0)
}

fn test_quartic_ease_in_out() {
	// p < 0.5
	assert compare(easings.quartic_ease_in_out(0.4), 0.2048)
	// p >= 0.5
	assert compare(easings.quartic_ease_in_out(0.6), 0.7952)
}

// Quintic tests
fn test_quintic_ease_in() {
	assert compare(easings.quintic_ease_in(4), 1024.0)
}

fn test_quintic_ease_out() {
	assert compare(easings.quintic_ease_out(4), 244.0)
}

fn test_quintic_ease_in_out() {
	// p < 0.5
	assert compare(easings.quintic_ease_in_out(0.4), 0.16384)
	// p >= 0.5
	assert compare(easings.quintic_ease_in_out(0.6), 0.83616)
}

// Sine tests
fn test_sine_ease_in() {
	assert compare(easings.sine_ease_in(3), 1.0)
}

fn test_sine_ease_out() {
	assert compare(easings.sine_ease_out(3), 0.000000)
}

fn test_sine_ease_in_out() {
	assert compare(easings.sine_ease_in_out(3), 1.0)
}

// Circular tests
fn test_circular_ease_in() {
	assert compare(easings.circular_ease_in(0.4), 0.083485)
}

fn test_circular_ease_out() {
	assert compare(easings.circular_ease_out(0.4), 0.80)
}

fn test_circular_ease_in_out() {
	// p < 0.5
	assert compare(easings.circular_ease_in_out(0.4), 0.20)
	// p >= 0.5
	assert compare(easings.circular_ease_in_out(0.6), 0.80)
}

// Exponential tests
fn test_exponential_ease_in() {
	assert compare(easings.exponential_ease_in(2), 1024.0)
}

fn test_exponential_ease_out() {
	assert compare(easings.exponential_ease_out(2), 0.999999)
}

fn test_exponential_ease_in_out() {
	// p = 0
	assert compare(easings.exponential_ease_in_out(0), 0.0)
	// p = 1
	assert compare(easings.exponential_ease_in_out(1), 1.0)
	// p < 0.5
	assert compare(easings.exponential_ease_in_out(0.4), 0.125)
	// p >= 0.5
	assert compare(easings.exponential_ease_in_out(0.6), 0.875)
}

// Elastic tests
fn test_elastic_ease_in() {
	assert compare(easings.elastic_ease_in(2), 0.0)
}

fn test_elastic_ease_out() {
	assert compare(easings.elastic_ease_out(2), 1.0)
}

fn test_elastic_ease_in_out() {
	// p < 0.5
	assert compare(easings.elastic_ease_in_out(0.4), 0.073473)
	// p >= 0.5
	assert compare(easings.elastic_ease_in_out(0.6), 1.073473)
}

// Back tests
fn test_back_ease_in() {
	assert compare(easings.back_ease_in(2), 8.0)
}

fn test_back_ease_out() {
	assert compare(easings.back_ease_out(2), 2.0)
}

fn test_back_ease_in_out() {
	// p < 0.5
	assert compare(easings.back_ease_in_out(0.4), 0.020886)
	// p >= 0.5
	assert compare(easings.back_ease_in_out(0.6), 0.979114)
}

// Bounce tests
fn test_bounce_ease_in() {
	assert compare(easings.bounce_ease_in(2), -6.562500)
}

fn test_bounce_ease_out() {
	// p < 4 / 11.0
	assert compare(easings.bounce_ease_out(0.35), 0.926406)
	// p < 8.0 / 11.0
	assert compare(easings.bounce_ease_out(0.70), 0.916750)
	// p < 9.0 / 10.0
	assert compare(easings.bounce_ease_out(0.89), 0.980365)
	// p >= 9.0 / 10.0
	assert compare(easings.bounce_ease_out(0.91), 0.990280)
}

fn test_bounce_ease_in_out() {
	// p < 0.5
	assert compare(easings.bounce_ease_in_out(0.4), 0.348750)
	// p >= 0.5
	assert compare(easings.bounce_ease_in_out(0.6), 0.651250)
}

// Helper method for comparing floats
fn compare(x f64, y f64) bool {
	tolerance := 1e-5
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	diff := math.abs(x - y)
	mean := math.abs(x + y) / 2.0
	return if math.is_nan(diff / mean) { true } else { ((diff / mean) < tolerance) }
}
