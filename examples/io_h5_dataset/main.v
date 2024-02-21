import vsl.inout.h5
import math.stats
import rand

fn main() {
	linedata := []f64{len: 21, init: (0 * index) + rand.f64()}
	mut meanv := 0.0
	hdffile := 'hdffile.h5'

	meanv = stats.mean(linedata)

	f := h5.Hdf5File.new(hdffile)!
	f.write_dataset1d('/randdata', linedata)!
	f.write_attribute('/randdata', 'mean', meanv)!
	f.close()
}
