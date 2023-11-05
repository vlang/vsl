import vsl.easings
import math
import vsl.float.float64

// Linear tests
fn test_linear_interpolation() {
	assert float64.tolerance(easings.linear_interpolation(2), 2.0, 1e-5)
}

// Quadratic tests
fn test_quadratic_ease_in() {
	assert float64.tolerance(easings.quadratic_ease_in(2), 4.0, 1e-5)
}

fn test_quadratic_ease_out() {
	assert float64.tolerance(easings.quadratic_ease_out(5), -15.0, 1e-5)
}

fn test_quadratic_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.quadratic_ease_in_out(0.4), 0.32, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.quadratic_ease_in_out(0.6), 0.68, 1e-5)
}

// Cubic tests
fn test_cubic_ease_in() {
	assert float64.tolerance(easings.cubic_ease_in(3), 27.0, 1e-5)
}

fn test_cubic_ease_out() {
	assert float64.tolerance(easings.cubic_ease_out(4), 28.0, 1e-5)
}

fn test_cubic_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.cubic_ease_in_out(0.4), 0.256, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.cubic_ease_in_out(0.6), 0.744, 1e-5)
}

// Quadratic tests
fn test_quartic_ease_in() {
	assert float64.tolerance(easings.quartic_ease_in(3), 81.0, 1e-5)
}

fn test_quartic_ease_out() {
	assert float64.tolerance(easings.quartic_ease_out(3), -15.0, 1e-5)
}

fn test_quartic_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.quartic_ease_in_out(0.4), 0.2048, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.quartic_ease_in_out(0.6), 0.7952, 1e-5)
}

// Quintic tests
fn test_quintic_ease_in() {
	assert float64.tolerance(easings.quintic_ease_in(4), 1024.0, 1e-5)
}

fn test_quintic_ease_out() {
	assert float64.tolerance(easings.quintic_ease_out(4), 244.0, 1e-5)
}

fn test_quintic_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.quintic_ease_in_out(0.4), 0.16384, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.quintic_ease_in_out(0.6), 0.83616, 1e-5)
}

// Sine tests
fn test_sine_ease_in() {
	assert float64.tolerance(easings.sine_ease_in(3), 1.0, 1e-5)
}

fn test_sine_ease_out() {
	assert float64.tolerance(easings.sine_ease_out(3), 0.000000, 1e-5)
}

fn test_sine_ease_in_out() {
	assert float64.tolerance(easings.sine_ease_in_out(3), 1.0, 1e-5)
}

// Circular tests
fn test_circular_ease_in() {
	assert float64.tolerance(easings.circular_ease_in(0.4), 0.083485, 1e-5)
}

fn test_circular_ease_out() {
	assert float64.tolerance(easings.circular_ease_out(0.4), 0.80, 1e-5)
}

fn test_circular_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.circular_ease_in_out(0.4), 0.20, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.circular_ease_in_out(0.6), 0.80, 1e-5)
}

// Exponential tests
fn test_exponential_ease_in() {
	assert float64.tolerance(easings.exponential_ease_in(2), 1024.0, 1e-5)
}

fn test_exponential_ease_out() {
	assert float64.tolerance(easings.exponential_ease_out(2), 0.999999, 1e-5)
}

fn test_exponential_ease_in_out() {
	// p = 0
	assert float64.tolerance(easings.exponential_ease_in_out(0), 0.0, 1e-5)
	// p = 1
	assert float64.tolerance(easings.exponential_ease_in_out(1), 1.0, 1e-5)
	// p < 0.5
	assert float64.tolerance(easings.exponential_ease_in_out(0.4), 0.125, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.exponential_ease_in_out(0.6), 0.875, 1e-5)
}

// Elastic tests
fn test_elastic_ease_in() {
	assert float64.tolerance(easings.elastic_ease_in(2), 0.0, 1e-5)
}

fn test_elastic_ease_out() {
	assert float64.tolerance(easings.elastic_ease_out(2), 1.0, 1e-5)
}

fn test_elastic_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.elastic_ease_in_out(0.4), 0.073473, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.elastic_ease_in_out(0.6), 1.073473, 1e-5)
}

// Back tests
fn test_back_ease_in() {
	assert float64.tolerance(easings.back_ease_in(2), 8.0, 1e-5)
}

fn test_back_ease_out() {
	assert float64.tolerance(easings.back_ease_out(2), 2.0, 1e-5)
}

fn test_back_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.back_ease_in_out(0.4), 0.020886, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.back_ease_in_out(0.6), 0.979114, 1e-5)
}

// Bounce tests
fn test_bounce_ease_in() {
	assert float64.tolerance(easings.bounce_ease_in(2), -6.562500, 1e-5)
}

fn test_bounce_ease_out() {
	// p < 4 / 11.0
	assert float64.tolerance(easings.bounce_ease_out(0.35), 0.926406, 1e-5)
	// p < 8.0 / 11.0
	assert float64.tolerance(easings.bounce_ease_out(0.70), 0.916750, 1e-5)
	// p < 9.0 / 10.0
	assert float64.tolerance(easings.bounce_ease_out(0.89), 0.980365, 1e-5)
	// p >= 9.0 / 10.0
	assert float64.tolerance(easings.bounce_ease_out(0.91), 0.990280, 1e-5)
}

fn test_bounce_ease_in_out() {
	// p < 0.5
	assert float64.tolerance(easings.bounce_ease_in_out(0.4), 0.348750, 1e-5)
	// p >= 0.5
	assert float64.tolerance(easings.bounce_ease_in_out(0.6), 0.651250, 1e-5)
}
