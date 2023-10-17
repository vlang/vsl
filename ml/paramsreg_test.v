module ml

import vsl.float.float64

fn test_params_reg() {
	nb_features := 3
	mut params := ParamsReg.new[f64](nb_features)
	params.theta[0] = 1
	params.theta[1] = 2
	params.theta[2] = 3
	params.bias = 4
	params.lambda = 0.1
	params.degree = 3
	assert params.theta == [1.0, 2, 3]
	assert float64.tolerance(params.bias, 4, 1e-15)
	assert float64.tolerance(params.lambda, 0.1, 1e-15)
	assert params.degree == 3
	assert params.bkp_theta == [0.0, 0, 0]
	assert float64.tolerance(params.bkp_bias, 0, 1e-15)
	assert float64.tolerance(params.bkp_bias, 0, 1e-15)
	assert params.bkp_degree == 0

	params.backup()
	assert params.bkp_theta == [1.0, 2, 3]
	assert float64.tolerance(params.bkp_bias, 4, 1e-15)
	assert float64.tolerance(params.bkp_lambda, 0.1, 1e-15)
	assert params.bkp_degree == 3

	params.theta[1] = -2
	params.bias = -4
	params.lambda = 0.01
	params.degree = 4
	assert params.theta == [1.0, -2, 3]
	assert float64.tolerance(params.bias, -4, 1e-15)
	assert float64.tolerance(params.lambda, 0.01, 1e-15)
	assert params.degree == 4
	assert params.bkp_theta == [1.0, 2, 3]
	assert float64.tolerance(params.bkp_bias, 4.0, 1e-15)
	assert float64.tolerance(params.bkp_lambda, 0.1, 1e-15)
	assert params.bkp_degree == 3
}
