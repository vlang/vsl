import fit
import vsl.vmath

fn test_linear_fit01() {
	// data
	x := [1.0, 2, 3, 4]
	y := [1.0, 2, 3, 4]
	a, b, sigma_a, sigma_b, chi_2 := fit.linear_sigma(x, y)
	assert compare(a, 0.0)
	assert compare(b, 1.0)
	assert compare(sigma_a, 0.0)
	assert compare(sigma_b, 0.0)
	assert compare(chi_2, 0.0)
}

fn test_linear_fit02() {
	// data
	x := [1.0, 2, 3, 4]
	y := [
		6.0,
		5,
		7,
		10,
	]
	a, b := fit.linear(x, y)
	assert compare(a, 3.5)
	assert compare(b, 1.4)
}

// Helper method for comparing floats
fn compare(x f64, y f64) bool {
	tolerance := 0.00001
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	diff := vmath.abs(x - y)
	mean := vmath.abs(x + y) / 2.0
	return if vmath.is_nan(diff / mean) {
		true
	} else {
		((diff / mean) < tolerance)
	}
}
