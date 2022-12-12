import hdf5
import math

#flag -I/usr/local/include
#flag -L/usr/local/lib

// ex1
// A simple 1d relaxation problem.  Write the results
// and two attributes of the calculation to an HDF5 file.
// To see the results, use `h5dump ex1_hdffile.h5`
fn main() {
	mut linedata := []f64{len: 21}
	mut newv := f64(0)
	hdffile := c'ex1_hdffile.h5'
	mut rounds := i32(0)

	linedata[0] = f64(-2.0)
	linedata[20] = f64(3.0)
	mut maxdiff := f64(0.0)

	for loop in 0 .. 1000 {
		maxdiff = -math.max_f64
		for i in 1 .. linedata.len - 1 {
			newv = (linedata[i - 1] + linedata[i] + linedata[i + 1]) / 3.00
			maxdiff = math.max(maxdiff, math.abs(newv - linedata[i]))
			linedata[i] = newv
		}
		rounds = loop
		if maxdiff < 0.0001 {
			break
		}
	}
	f := hdf5.new_file(hdffile)?
	f.write_dataset1d(c'linedata', linedata)?
	f.write_attribute(c'linedata', c'rounds', rounds)?
	f.write_attribute(c'linedata', c'maxdiff', maxdiff)?
	f.close()
}
