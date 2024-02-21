import vsl.fit
import vsl.float.float64

fn test_linear_fit01() {
	// data
	x := [1.0, 2, 3, 4]
	y := [1.0, 2, 3, 4]
	a, b, sigma_a, sigma_b, chi_2 := fit.linear_sigma(x, y)
	assert float64.tolerance(a, 0.0, 1e-5)
	assert float64.tolerance(b, 1.0, 1e-5)
	assert float64.tolerance(sigma_a, 0.0, 1e-5)
	assert float64.tolerance(sigma_b, 0.0, 1e-5)
	assert float64.tolerance(chi_2, 0.0, 1e-5)
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
	assert float64.tolerance(a, 3.5, 1e-5)
	assert float64.tolerance(b, 1.4, 1e-5)
}
