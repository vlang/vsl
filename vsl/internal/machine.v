// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module internal

pub const (
	/* magic constants; mostly for the benefit of the implementation */

	dbl_epsilon             = 2.2204460492503131e-16
	sqrt_dbl_epsilon        = 1.4901161193847656e-08
	root3_dbl_epsilon       = 6.0554544523933429e-06
	root4_dbl_epsilon       = 1.2207031250000000e-04
	root5_dbl_epsilon       = 7.4009597974140505e-04
	root6_dbl_epsilon       = 2.4607833005759251e-03
	log_dbl_epsilon         = -3.6043653389117154e+01

	dbl_min                 = 2.2250738585072014e-308
	sqrt_dbl_min            = 1.4916681462400413e-154
	root3_dbl_min           = 2.8126442852362996e-103
	root4_dbl_min           = 1.2213386697554620e-77
	root5_dbl_min           = 2.9476022969691763e-62
	root6_dbl_min           = 5.3034368905798218e-52
	log_dbl_min             = -7.0839641853226408e+02

	dbl_max                 = 1.7976931348623157e+308
	sqrt_dbl_max            = 1.3407807929942596e+154
	root3_dbl_max           = 5.6438030941222897e+102
	root4_dbl_max           = 1.1579208923731620e+77
	root5_dbl_max           = 4.4765466227572707e+61
	root6_dbl_max           = 2.3756689782295612e+51
	log_dbl_max             = 7.0978271289338397e+02

	flt_epsilon             = 1.1920928955078125e-07
	sqrt_flt_epsilon        = 3.4526698300124393e-04
	root3_flt_epsilon       = 4.9215666011518501e-03
	root4_flt_epsilon       = 1.8581361171917516e-02
	root5_flt_epsilon       = 4.1234622211652937e-02
	root6_flt_epsilon       = 7.0153878019335827e-02
	log_flt_epsilon         = -1.5942385152878742e+01

	flt_min                 = 1.1754943508222875e-38
	sqrt_flt_min            = 1.0842021724855044e-19
	root3_flt_min           = 2.2737367544323241e-13
	root4_flt_min           = 3.2927225399135965e-10
	root5_flt_min           = 2.5944428542140822e-08
	root6_flt_min           = 4.7683715820312542e-07
	log_flt_min             = -8.7336544750553102e+01

	flt_max                 = 3.4028234663852886e+38
	sqrt_flt_max            = 1.8446743523953730e+19
	root3_flt_max           = 6.9814635196223242e+12
	root4_flt_max           = 4.2949672319999986e+09
	root5_flt_max           = 5.0859007855960041e+07
	root6_flt_max           = 2.6422459233807749e+06
	log_flt_max             = 8.8722839052068352e+01

	sflt_epsilon            = 4.8828125000000000e-04
	sqrt_sflt_epsilon       = 2.2097086912079612e-02
	root3_sflt_epsilon      = 7.8745065618429588e-02
	root4_sflt_epsilon      = 1.4865088937534013e-01
	root5_sflt_epsilon      = 2.1763764082403100e-01
	root6_sflt_epsilon      = 2.8061551207734325e-01
	log_sflt_epsilon        = -7.6246189861593985e+00


	max_int_fact_arg        = 170
	max_dbl_fact_arg        = 171.0
	max_long_dbl_fact_arg   = 1755.5

	/* MACHINE CONSTANTS! */

	/* a little internal backwards compatibility */
	mach_eps                = dbl_epsilon

	/* Here are the constants related to or derived from
	* machine constants. These are not to be confused with
	* the constants that define various precision levels
	* for the precision/error system.
	*
	* This information is determined at configure time
	* and is platform dependent. Edit at your own risk.
	*/

	/* machine precision constants */
	/* mach_eps             = 1.0e-15 */
	sqrt_mach_eps           =  3.2e-08
	root3_mach_eps          = 1.0e-05
	root4_mach_eps          = 0.000178
	root5_mach_eps          = 0.00100
	root6_mach_eps          = 0.00316
	log_mach_eps            =  -34.54
)
