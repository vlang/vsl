module fun

import vsl.float.float64
import math
import vsl.util

fn test_sinusoid_01() {
	// data
	pi := math.pi // 3.14159265359...
	t := 1.5 // period [s]
	a0 := 1.7 // mean value
	c1 := 1.0 // amplitude
	theta := pi / 3.0 // phase shift [rad]
	sa := Sinusoid.essential(t, a0, c1, theta)
	sb := Sinusoid.basis(t, a0, sa.a[1], sa.b[1])

	// check setup data
	assert float64.tolerance(sa.period, sb.period, 1e-15)
	assert float64.tolerance(sa.frequency, sb.frequency, 1e-15)
	assert float64.tolerance(sa.phase_shift, sb.phase_shift, 1e-15)
	assert float64.tolerance(sa.mean_value, sb.mean_value, 1e-15)
	assert float64.tolerance(sa.amplitude, sb.amplitude, 1e-15)
	assert float64.tolerance(sa.angular_freq, sb.angular_freq, 1e-15)
	assert float64.tolerance(sa.time_shift, sb.time_shift, 1e-15)

	for i in 0 .. sa.a.len {
		assert float64.tolerance(sa.a[i], sb.a[i], 1e-15)
	}

	for i in 0 .. sa.b.len {
		assert float64.tolerance(sa.b[i], sb.b[i], 1e-15)
	}

	// check essen vs basis
	tt := util.lin_space(-sa.time_shift, 2.5, 7)
	mut y1 := []f64{len: tt.len}
	mut y2 := []f64{len: tt.len}
	for i in 0 .. tt.len {
		y1[i] = sa.yessen(tt[i])
		y2[i] = sb.ybasis(tt[i])
	}

	for i in 0 .. y1.len {
		assert float64.tolerance(y1[i], y2[i], 1e-15)
	}

	// check periodicity
	assert sa.test_periodicity(0, 4 * pi, 10)
}
