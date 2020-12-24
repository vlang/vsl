module util

import vsl.vmath as math
import vsl.errno

pub const (
	xdelzero = 1e-10 // minimum distance between coordinates; i.e. xmax[i]-xmin[i] mininum
)

// BinEntry holds data of an entry to bin
pub struct BinEntry {
pub mut:
	id    int // object Id
	x     []f64 // entry coordinate (read only)
	extra voidptr // any entity attached to this entry
}

// Bin defines one bin in Bins (holds entries for search)
pub struct Bin {
pub mut:
	index   int // index of bin
	entries []&BinEntry // entries
}

// Bins implements a set of bins holding entries and is used to fast search entries by given coordinates.
pub struct Bins {
mut:
	tmp  []int // [ndim] temporary (auxiliary) slice
pub mut:
	ndim int // space dimension
	xmin []f64 // [ndim] left/lower-most point
	xmax []f64 // [ndim] right/upper-most point
	xdel []f64 // [ndim] the lengths along each direction (whole box)
	size []f64 // size of bins
	ndiv []int // [ndim] number of divisions along each direction
	all  []&Bin // [nbins] all bins (there will be an extra "ghost" bin along each dimension)
}

// new_bins initialise bins structure
//   xmin -- [ndim] min/initial coordinates of the whole space (box/cube)
//   xmax -- [ndim] max/final coordinates of the whole space (box/cube)
//   ndiv -- [ndim] number of divisions for xmax-xmin
pub fn new_bins(xmin []f64, xmax []f64, ndiv_ []int) Bins {
	mut ndiv := ndiv_.clone()
	mut o := Bins{}
	// check for out-of-range values
	o.ndim = xmin.len
	o.xmin = xmin
	o.xmax = xmax
	assert xmin.len == xmax.len
	assert xmin.len == ndiv.len
	if xmin.len < 2 || xmin.len > 3 {
		errno.vsl_panic('sizes of xmin and xmax must be the same and equal to either 2 or 3',
			.efailed)
	}
	// allocate slices with max lengths and number of division
	o.xdel = []f64{len: o.ndim}
	o.size = []f64{len: o.ndim}
	for k in 0 .. o.ndim {
		if ndiv[k] < 1 {
			ndiv[k] = 1
		}
		o.xdel[k] = o.xmax[k] - o.xmin[k]
		o.size[k] = o.xdel[k] / f64(ndiv[k])
		if o.xdel[k] < xdelzero {
			errno.vsl_panic('xmax[$k]-xmin[$k]=${o.xdel[k]} must be greater than $xdelzero',
				.efailed)
		}
	}
	// number of divisions
	o.ndiv = []int{len: o.ndim}
	mut nbins := 1
	for k in 0 .. o.ndim {
		o.ndiv[k] = int(o.xdel[k] / o.size[k])
		nbins *= o.ndiv[k]
	}
	// other slices
	o.all = []&Bin{len: nbins}
	o.tmp = []int{len: o.ndim}
	return o
}

// append adds a new entry {x, id, something} into the bins structure
pub fn (mut o Bins) append(x []f64, id int, extra voidptr) {
	idx := o.calc_index(x)
	if idx < 0 {
		errno.vsl_panic('coordinates $x are out of range', .erange)
	}
	bin := o.find_bin_by_index(idx)
	if isnil(bin) {
		errno.vsl_panic('bin index $idx is out of range', .erange)
	}
	xcopy := x.clone()
	entry := BinEntry{id, xcopy, extra}
	mut entries := bin.entries
	entries << &entry
}

// clear clears all biBinsns
pub fn (mut o Bins) clear() {
	o.all = []&Bin{}
}

// find_bin_by_index finds or allocate new bin corresponding to index idx
pub fn (mut o Bins) find_bin_by_index(idx int) &Bin {
	// check
	if idx < 0 || idx >= o.all.len {
		return voidptr(0)
	}
	// allocate new bin if necessary
	if isnil(o.all[idx]) {
		new_bin := Bin{
			index: idx
		}
		o.all[idx] = &new_bin
	}
	return o.all[idx]
}

// calc_index calculates the bin index where the point x is
// returns -1 if out-of-range
pub fn (mut o Bins) calc_index(x []f64) int {
	for k in 0 .. o.ndim {
		if x[k] < o.xmin[k] || x[k] > o.xmax[k] {
			return -1
		}
		o.tmp[k] = int((x[k] - o.xmin[k]) / o.size[k])
		if o.tmp[k] == o.ndiv[k] { // it's exactly on max edge => select inner bin
			o.tmp[k]-- // move to the inside
		}
	}
	mut idx := o.tmp[0] + o.tmp[1] * o.ndiv[0]
	if o.ndim > 2 {
		idx += o.tmp[2] * o.ndiv[0] * o.ndiv[1]
	}
	return idx
}
