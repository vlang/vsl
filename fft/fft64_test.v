import vsl.fft

fn test_fft() {
	// a simple FFT
	mut bline := []f64{len: 0, cap: 9}

	// two element FT

	bline = [f64(1.0), 0]
	println('orig   ${bline}')

	mut p := fft.create_plan(bline)?
	mut x := fft.forward_fft(p, bline)
	println('forw ${x} ${bline}')
	assert bline[0] == f64(1.0)
	assert bline[1] == f64(1.0)

	x = fft.backward_fft(p, bline)
	println('back ${x} ${bline}')
	assert bline[0] == f64(2.0)
	assert bline[1] == f64(0.0)
	println('')

	// four element FT

	bline = [f64(0.0), 1, 0, 0]
	println('orig   ${bline}')

	p = fft.create_plan(bline)?
	mut y := fft.forward_fft(p, bline)
	println('forw ${y} ${bline}')
	assert bline[0] == f64(1.0)
	assert bline[1] == f64(0.0)
	assert bline[2] == f64(-1.0)
	assert bline[3] == f64(-1.0)

	x = fft.backward_fft(p, bline)
	println('back ${x} ${bline}')
	assert bline[0] == f64(0.0)
	assert bline[1] == f64(4.0)
	assert bline[2] == f64(0.0)
	assert bline[3] == f64(0.0)
	println('')

	// a signal

	// wolfram says:
	// 2 Fourier[{0.5, 0.5, 1, 2}]
	// is
	// {4 + 0 i, -0.5 - 1.5 i, -1 + 0 i, -0.5 + 1.5 i}

	bline = [f64(0.5), 0.5, 1, 2]
	println('sgnl ${y} ${bline}')
	y = fft.forward_fft(p, bline)
	println('forw ${y} ${bline}')
	assert bline[0] == f64(4.0)
	assert bline[1] == f64(-0.5)
	assert bline[2] == f64(1.5)
	assert bline[3] == f64(-1.0)
	println('wolf 0 {4, -0.5 - 1.5 i, -1, -0.5 + 1.5 i}')
	println('')

	// wolfram says:
	// 2 Fourier[{-0.5, -0.5, 0, 1}]
	// is
	// {0 i, -0.5 - 1.5 i, -1 + 0 i, -0.5 + 1.5 i}

	// same as above without a dc offset
	bline = [f64(0.5), 0.5, 1, 2].map(it - f64(1.0))
	println('sgnl ${y} ${bline}')
	y = fft.forward_fft(p, bline)
	println('forw ${y} ${bline}')
	assert bline[0] == f64(0.0)
	assert bline[1] == f64(-0.5)
	assert bline[2] == f64(1.5)
	assert bline[3] == f64(-1.0)
	println('wolf 0 {0, -0.5 - 1.5 i, -1, -0.5 + 1.5 i}')
	println('')

	// bigger signal

	bline = [f64(0.5), 0.5, 1, 2, 2, 2, 2, 3]
	println('sgnl ${y} ${bline}')
	p = fft.create_plan(bline)?
	y = fft.forward_fft(p, bline)
	println('forw ${y} ${bline}')
	assert bline[0] == 13.0
	assert bline[3] == -0.5
	assert bline[4] == 2.5
	assert bline[7] == -2.0
	println('wolf 0 { 12.998 + 0. i, -1.85647 - 2.76735 i, -0.499924 - 2.49962 i, -1.14627 - 0.767651 i, -1.9997 + 0. i, -1.14627 + 0.767651 i, -0.499924 + 2.49962 i, -1.85647 + 2.76735 i}')
	println('')
}
