import vsl.fft

fn test_fft() {
	// a simple FFT
	mut aline := []f32{len: 0, cap: 9}

	// two element FT

	aline = [f32(1.0), 0]
	println('orig   ${aline}')

	mut p := fft.create_plan(aline)?
	mut x := fft.forward_fft(p, aline)
	println('forw ${x} ${aline}')
	assert aline[0] == f32(1.0)
	assert aline[1] == f32(1.0)

	x = fft.backward_fft(p, aline)
	println('back ${x} ${aline}')
	assert aline[0] == f32(2.0)
	assert aline[1] == f32(0.0)
	println('')

	// four element FT

	aline = [f32(0.0), 1, 0, 0]
	println('orig   ${aline}')

	p = fft.create_plan(aline)?
	mut y := fft.forward_fft(p, aline)
	println('forw ${y} ${aline}')
	assert aline[0] == f32(1.0)
	assert aline[1] == f32(0.0)
	assert aline[2] == f32(-1.0)
	assert aline[3] == f32(-1.0)

	x = fft.backward_fft(p, aline)
	println('back ${x} ${aline}')
	assert aline[0] == f32(0.0)
	assert aline[1] == f32(4.0)
	assert aline[2] == f32(0.0)
	assert aline[3] == f32(0.0)
	println('')

	// a signal

	// wolfram says:
	// 2 Fourier[{0.5, 0.5, 1, 2}]
	// is
	// {4 + 0 i, -0.5 - 1.5 i, -1 + 0 i, -0.5 + 1.5 i}

	aline = [f32(0.5), 0.5, 1, 2]
	println('sgnl ${y} ${aline}')
	y = fft.forward_fft(p, aline)
	println('forw ${y} ${aline}')
	assert aline[0] == f32(4.0)
	assert aline[1] == f32(-0.5)
	assert aline[2] == f32(1.5)
	assert aline[3] == f32(-1.0)
	println('wolf 0 {4, -0.5 - 1.5 i, -1, -0.5 + 1.5 i}')
	println('')

	// wolfram says:
	// 2 Fourier[{-0.5, -0.5, 0, 1}]
	// is
	// {0 i, -0.5 - 1.5 i, -1 + 0 i, -0.5 + 1.5 i}

	// same as above without a dc offset
	aline = [f32(0.5), 0.5, 1, 2].map(it - f32(1.0))
	println('sgnl ${y} ${aline}')
	y = fft.forward_fft(p, aline)
	println('forw ${y} ${aline}')
	assert aline[0] == f32(0.0)
	assert aline[1] == f32(-0.5)
	assert aline[2] == f32(1.5)
	assert aline[3] == f32(-1.0)
	println('wolf 0 {0, -0.5 - 1.5 i, -1, -0.5 + 1.5 i}')
	println('')

	// bigger signal

	aline = [f32(0.5), 0.5, 1, 2, 2, 2, 2, 3]
	println('sgnl ${y} ${aline}')
	p = fft.create_plan(aline)?
	y = fft.forward_fft(p, aline)
	println('forw ${y} ${aline}')
	assert aline[0] == 13.0
	assert aline[3] == -0.5
	assert aline[4] == 2.5
	assert aline[7] == -2.0
	println('wolf 0 { 12.998 + 0. i, -1.85327 - 2.76735 i, -0.499924 - 2.49962 i, -1.14627 - 0.767651 i, -1.9997 + 0. i, -1.14627 + 0.767651 i, -0.499924 + 2.49962 i, -1.85327 + 2.76735 i}')
	println('')
}
