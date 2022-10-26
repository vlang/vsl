module fun

import vsl.float.float64

fn test_interp01() {
	xx := [0.0, 1, 2, 3, 4, 5]
	yy := [0.50, 0.20, 0.20, 0.05, 0.01, 0.00]

	mut o := new_data_interp('lin', 1, xx, yy)

	for i, x in xx {
		assert float64.veryclose(o.p(x), yy[i])
	}

	xref := [1.0 / 3.0, 2.5, 2.0 / 3.0, 1.1, 1.5, 3.5, 4.5]
	yref := [0.4, 0.125, 0.3, 0.2, 0.2, 0.03, 0.005]
	for i, x in xref {
		res := float64.close(o.p(x), yref[i])
		eprintln('>> i: ${i:5} | res: $res | o.p(x): ${o.p(x):20.20f} | yref[i]: ${yref[i]:20.20f} ')
		assert res
	}
}

fn test_interp02() {
	xx := [0.0, 1, 2, 3, 4, 5]
	yy := [0.50, 0.20, 0.20, 0.05, 0.01, 0.00]

	for p in [1, 2, 3] {
		mut o := new_data_interp('poly', p, xx, yy)

		for i, x in xx {
			assert float64.veryclose(o.p(x), yy[i])
		}

		if o.m == 2 {
			xref := [1.0 / 3.0, 2.5, 2.0 / 3.0, 1.1, 1.5, 3.5, 4.5]
			yref := [0.4, 0.125, 0.3, 0.2, 0.2, 0.03, 0.005]
			for i, x in xref {
				assert float64.close(o.p(x), yref[i])
			}
		}
	}
}
