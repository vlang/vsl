module prec

import math.internal as mathinternal

// contants to do fine tuning of precision for the functions
// implemented in pure V.
// This can be fine tuned for each function, but the default
// values are good enough for most cases.
// Optimizing this in Vlib makes direct impact on the performance
// of VSL programs.
pub const f64_epsilon = mathinternal.f64_epsilon
pub const sqrt_f64_epsilon = mathinternal.sqrt_f64_epsilon
pub const root3_f64_epsilon = mathinternal.root3_f64_epsilon
pub const root4_f64_epsilon = mathinternal.root4_f64_epsilon
pub const root5_f64_epsilon = mathinternal.root5_f64_epsilon
pub const root6_f64_epsilon = mathinternal.root6_f64_epsilon
pub const log_f64_epsilon = mathinternal.log_f64_epsilon
pub const f64_min = mathinternal.f64_min
pub const sqrt_f64_min = mathinternal.sqrt_f64_min
pub const root3_f64_min = mathinternal.root3_f64_min
pub const root4_f64_min = mathinternal.root4_f64_min
pub const root5_f64_min = mathinternal.root5_f64_min
pub const root6_f64_min = mathinternal.root6_f64_min
pub const log_f64_min = mathinternal.log_f64_min
pub const f64_max = mathinternal.f64_max
pub const sqrt_f64_max = mathinternal.sqrt_f64_max
pub const root3_f64_max = mathinternal.root3_f64_max
pub const root4_f64_max = mathinternal.root4_f64_max
pub const root5_f64_max = mathinternal.root5_f64_max
pub const root6_f64_max = mathinternal.root6_f64_max
pub const log_f64_max = mathinternal.log_f64_max
pub const f32_epsilon = mathinternal.f32_epsilon
pub const sqrt_f32_epsilon = mathinternal.sqrt_f32_epsilon
pub const root3_f32_epsilon = mathinternal.root3_f32_epsilon
pub const root4_f32_epsilon = mathinternal.root4_f32_epsilon
pub const root5_f32_epsilon = mathinternal.root5_f32_epsilon
pub const root6_f32_epsilon = mathinternal.root6_f32_epsilon
pub const log_f32_epsilon = mathinternal.log_f32_epsilon
pub const f32_min = mathinternal.f32_min
pub const sqrt_f32_min = mathinternal.sqrt_f32_min
pub const root3_f32_min = mathinternal.root3_f32_min
pub const root4_f32_min = mathinternal.root4_f32_min
pub const root5_f32_min = mathinternal.root5_f32_min
pub const root6_f32_min = mathinternal.root6_f32_min
pub const log_f32_min = mathinternal.log_f32_min
pub const f32_max = mathinternal.f32_max
pub const sqrt_f32_max = mathinternal.sqrt_f32_max
pub const root3_f32_max = mathinternal.root3_f32_max
pub const root4_f32_max = mathinternal.root4_f32_max
pub const root5_f32_max = mathinternal.root5_f32_max
pub const root6_f32_max = mathinternal.root6_f32_max
pub const log_f32_max = mathinternal.log_f32_max
pub const sflt_epsilon = mathinternal.sflt_epsilon
pub const sqrt_sflt_epsilon = mathinternal.sqrt_sflt_epsilon
pub const root3_sflt_epsilon = mathinternal.root3_sflt_epsilon
pub const root4_sflt_epsilon = mathinternal.root4_sflt_epsilon
pub const root5_sflt_epsilon = mathinternal.root5_sflt_epsilon
pub const root6_sflt_epsilon = mathinternal.root6_sflt_epsilon
pub const log_sflt_epsilon = mathinternal.log_sflt_epsilon
pub const max_int_fact_arg = mathinternal.max_int_fact_arg
pub const max_f64_fact_arg = mathinternal.max_f64_fact_arg
pub const max_long_f64_fact_arg = mathinternal.max_long_f64_fact_arg
