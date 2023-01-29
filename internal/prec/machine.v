module prec

import math.internal as mathinternal

// contants to do fine tuning of precision for the functions
// implemented in pure V.
// This can be fine tuned for each function, but the default
// values are good enough for most cases.
// Optimizing this in Vlib makes direct impact on the performance
// of VSL programs.
pub const (
	f64_epsilon           = mathinternal.f64_epsilon
	sqrt_f64_epsilon      = mathinternal.sqrt_f64_epsilon
	root3_f64_epsilon     = mathinternal.root3_f64_epsilon
	root4_f64_epsilon     = mathinternal.root4_f64_epsilon
	root5_f64_epsilon     = mathinternal.root5_f64_epsilon
	root6_f64_epsilon     = mathinternal.root6_f64_epsilon
	log_f64_epsilon       = mathinternal.log_f64_epsilon
	f64_min               = mathinternal.f64_min
	sqrt_f64_min          = mathinternal.sqrt_f64_min
	root3_f64_min         = mathinternal.root3_f64_min
	root4_f64_min         = mathinternal.root4_f64_min
	root5_f64_min         = mathinternal.root5_f64_min
	root6_f64_min         = mathinternal.root6_f64_min
	log_f64_min           = mathinternal.log_f64_min
	f64_max               = mathinternal.f64_max
	sqrt_f64_max          = mathinternal.sqrt_f64_max
	root3_f64_max         = mathinternal.root3_f64_max
	root4_f64_max         = mathinternal.root4_f64_max
	root5_f64_max         = mathinternal.root5_f64_max
	root6_f64_max         = mathinternal.root6_f64_max
	log_f64_max           = mathinternal.log_f64_max
	f32_epsilon           = mathinternal.f32_epsilon
	sqrt_f32_epsilon      = mathinternal.sqrt_f32_epsilon
	root3_f32_epsilon     = mathinternal.root3_f32_epsilon
	root4_f32_epsilon     = mathinternal.root4_f32_epsilon
	root5_f32_epsilon     = mathinternal.root5_f32_epsilon
	root6_f32_epsilon     = mathinternal.root6_f32_epsilon
	log_f32_epsilon       = mathinternal.log_f32_epsilon
	f32_min               = mathinternal.f32_min
	sqrt_f32_min          = mathinternal.sqrt_f32_min
	root3_f32_min         = mathinternal.root3_f32_min
	root4_f32_min         = mathinternal.root4_f32_min
	root5_f32_min         = mathinternal.root5_f32_min
	root6_f32_min         = mathinternal.root6_f32_min
	log_f32_min           = mathinternal.log_f32_min
	f32_max               = mathinternal.f32_max
	sqrt_f32_max          = mathinternal.sqrt_f32_max
	root3_f32_max         = mathinternal.root3_f32_max
	root4_f32_max         = mathinternal.root4_f32_max
	root5_f32_max         = mathinternal.root5_f32_max
	root6_f32_max         = mathinternal.root6_f32_max
	log_f32_max           = mathinternal.log_f32_max
	sflt_epsilon          = mathinternal.sflt_epsilon
	sqrt_sflt_epsilon     = mathinternal.sqrt_sflt_epsilon
	root3_sflt_epsilon    = mathinternal.root3_sflt_epsilon
	root4_sflt_epsilon    = mathinternal.root4_sflt_epsilon
	root5_sflt_epsilon    = mathinternal.root5_sflt_epsilon
	root6_sflt_epsilon    = mathinternal.root6_sflt_epsilon
	log_sflt_epsilon      = mathinternal.log_sflt_epsilon
	max_int_fact_arg      = mathinternal.max_int_fact_arg
	max_f64_fact_arg      = mathinternal.max_f64_fact_arg
	max_long_f64_fact_arg = mathinternal.max_long_f64_fact_arg
)
