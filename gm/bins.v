module gm

import math
import vsl.errors

pub const xdelzero = 1e-10 // minimum distance between coordinates; i.e. xmax[i]-xmin[i] mininum

// BinEntry holds data of an entry to bin
@[heap]
pub struct BinEntry {
pub mut:
	id    int     // object Id
	x     []f64   // entry coordinate (read only)
	extra voidptr // any entity attached to this entry
}

// Bin defines one bin in Bins (holds entries for search)
@[heap]
pub struct Bin {
pub mut:
	index   int         // index of bin
	entries []&BinEntry // entries
}

// Bins implements a set of bins holding entries and is used to fast search entries by given coordinates.
@[heap]
pub struct Bins {
mut:
	tmp []int // [ndim] temporary (auxiliary) slice
pub mut:
	ndim int    // space dimension
	xmin []f64  // [ndim] left/lower-most point
	xmax []f64  // [ndim] right/upper-most point
	xdel []f64  // [ndim] the lengths along each direction (whole box)
	size []f64  // size of bins
	ndiv []int  // [ndim] number of divisions along each direction
	all  []&Bin // [nbins] all bins (there will be an extra "ghost" bin along each dimension)
}

// Bins.new initialise bins structure
//   xmin -- [ndim] min/initial coordinates of the whole space (box/cube)
//   xmax -- [ndim] max/final coordinates of the whole space (box/cube)
//   ndiv -- [ndim] number of divisions for xmax-xmin
pub fn Bins.new(xmin []f64, xmax []f64, ndiv_ []int) &Bins {
	mut ndiv := ndiv_.clone()
	mut o := &Bins{}
	// check for out-of-range values
	o.ndim = xmin.len
	o.xmin = xmin
	o.xmax = xmax
	assert xmin.len == xmax.len
	assert xmin.len == ndiv.len
	if xmin.len < 2 || xmin.len > 3 {
		errors.vsl_panic('sizes of xmin and xmax must be the same and equal to either 2 or 3',
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
		if o.xdel[k] < gm.xdelzero {
			errors.vsl_panic('xmax[${k}]-xmin[${k}]=${o.xdel[k]} must be greater than ${gm.xdelzero}',
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
	o.all = unsafe { []&Bin{len: nbins} }
	o.tmp = []int{len: o.ndim}
	return o
}

// append adds a new entry {x, id, something} into the bins structure
pub fn (mut o Bins) append(x []f64, id int, extra voidptr) {
	idx := o.calc_index(x)
	if idx < 0 {
		errors.vsl_panic('coordinates ${x} are out of range', .erange)
	}
	mut bin := o.find_bin_by_index(idx)
	if isnil(bin) {
		errors.vsl_panic('bin index ${idx} is out of range', .erange)
	}
	xcopy := x.clone()
	bin.entries << &BinEntry{id, xcopy, extra}
}

// clear clears all biBinsns
pub fn (mut o Bins) clear() {
	o.all = []&Bin{}
}

// find_bin_by_index finds or allocate new bin corresponding to index idx
pub fn (mut o Bins) find_bin_by_index(idx int) &Bin {
	// check
	if idx < 0 || idx >= o.all.len {
		return unsafe { nil }
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

// find_closest returns the id of the entry whose coordinates are closest to x
//   id_closest  -- the id of the closest entity. return -1 if out-of-range or not found
//   sq_dist_min -- the minimum distance (squared) between x and the closest entity in the same bin
//
//  NOTE: find_closest does search the whole area.
//        It only locates neighbours in the same bin where the given x is located.
//        So, if there area no entries in the bin containing x, no entry will be found.
//
pub fn (mut o Bins) find_closest(x []f64) (int, f64) {
	// set "not-found" results
	mut id_closest := -1
	mut sq_dist_min := math.inf(1)
	// index and check
	idx := o.calc_index(x)
	if idx < 0 {
		// out of range
		return id_closest, sq_dist_min
	}
	// search for the closest point
	bin := o.find_bin_by_index(idx)
	for entry in bin.entries {
		mut d := 0.0
		for k in 0 .. o.ndim {
			d += math.pow(x[k] - entry.x[k], 2.0)
		}
		if d < sq_dist_min {
			id_closest = entry.id
			sq_dist_min = d
		}
	}
	return id_closest, sq_dist_min
}

pub type PointsDiffFn = fn (is_old int, x_new []f64) bool

// find_closest_and_append finds closest point and, if not found, append to bins with a new Id
//   input:
//     next_id -- is the Id of the next point. Will be incremented if x is a new point to be added.
//     x       -- is the point to be added
//     extra   -- extra information attached to point
//     rad_tol -- is the tolerance for the radial distance (i.e. NOT squared) to decide
//                whether a new point will be appended or not.
//     diff    -- [optional] a function for further check that the new and an eventual existent
//                points are really different, even after finding that they coincide (within tol)
//   output:
//     id       -- the id attached to x
//     existent -- flag telling if x was found, based on given tolerance
pub fn (mut o Bins) find_closest_and_append(mut next_id &int, x []f64, extra voidptr, rad_tol f64, diff PointsDiffFn) (int, bool) {
	// try to find another close point
	id_closest, sq_dist_min := o.find_closest(x)
	// new point for sure; i.e no other point was found
	id := *next_id
	if id_closest < 0 {
		o.append(x, id, extra)
		(*next_id)++
		return id, false
	}
	// new point, distant from the point just found
	dist := math.sqrt(sq_dist_min)
	if dist > rad_tol {
		o.append(x, id, extra)
		(*next_id)++
		return id, false
	}
	// further check
	if !isnil(diff) {
		if diff(id_closest, x) {
			o.append(x, id, extra)
			(*next_id)++
			return id, false
		}
	}
	// existent point
	return id_closest, true
}

// find_along_segment gets the ids of entries that lie close to a segment
//  Note: the initial (xi) and final (xf) points on segment define a bounding box to filter points
pub fn (mut o Bins) find_along_segment(xi_ []f64, xf_ []f64, tol f64) []int {
	mut xi := xi_.clone()
	mut xf := xf_.clone()
	// auxiliary variables
	mut sbins := []&Bin{} // selected bins
	mut lmax := math.max(o.size[0], o.size[1])
	if o.ndim == 3 {
		lmax = math.max(lmax, o.size[2])
	}
	btol := 0.9 * lmax // tolerance for bins
	pi := point_from_vector(xi, o.ndim)
	pf := point_from_vector(xf, o.ndim)
	if o.ndim != 3 {
		xi = [xi[0], xi[1], -1.0]
		xf = [xf[0], xf[1], 1.0]
	}
	// loop along all bins
	nxy := o.ndiv[0] * o.ndiv[1]
	for idx, bin in o.all {
		// skip empty bins
		if isnil(bin) {
			continue
		}
		// coordinates of bin center
		i := idx % o.ndiv[0] // indices representing bin
		j := (idx % nxy) / o.ndiv[0]
		mut x := o.xmin[0] + f64(i) * o.size[0] // coordinates of bin corner
		mut y := o.xmin[1] + f64(j) * o.size[1]
		mut z := 0.0
		x += o.size[0] / 2.0
		y += o.size[1] / 2.0
		if o.ndim == 3 {
			k := idx / nxy
			z = o.xmin[2] + f64(k) * o.size[2]
			z += o.size[2] / 2.0
		}
		// check if bin is near line
		p := Point.new(x, y, z)
		d := dist_point_line(p, pi, pf, tol)
		if d <= btol {
			sbins << bin
		}
	}
	// entries ids
	mut ids := []int{}
	// find closest points
	for bin in sbins {
		for entry in bin.entries {
			x := entry.x[0]
			y := entry.x[1]
			mut z := 0.0
			if o.ndim == 3 {
				z = entry.x[0]
			}
			p := &Point{x, y, z}
			d := dist_point_line(p, pi, pf, tol)
			if d <= tol {
				if is_point_in(p, xi, xf, tol) {
					ids << entry.id
				}
			}
		}
	}
	return ids
}

// get_limits returns limigs of a specific bin
pub fn (o &Bins) get_limits(idx_bin int) ([]f64, []f64) {
	mut xmin := []f64{}
	mut xmax := []f64{}
	nxy := o.ndiv[0] * o.ndiv[1]
	i := idx_bin % o.ndiv[0]
	j := (idx_bin % nxy) / o.ndiv[0]
	if o.ndim == 2 {
		xmin = [o.xmin[0] + f64(i + 0) * o.size[0], o.xmin[1] + f64(j + 0) * o.size[1]]
		xmax = [o.xmin[0] + f64(i + 1) * o.size[0], o.xmin[1] + f64(j + 1) * o.size[1]]
	} else {
		k := idx_bin / nxy
		xmin = [o.xmin[0] + f64(i + 0) * o.size[0], o.xmin[1] + f64(j + 0) * o.size[1],
			o.xmin[2] + f64(k + 0) * o.size[2]]
		xmax = [o.xmin[0] + f64(i + 1) * o.size[0], o.xmin[1] + f64(j + 1) * o.size[1],
			o.xmin[2] + f64(k + 1) * o.size[2]]
	}
	return xmin, xmax
}

fn point_from_vector(v []f64, dim int) &Point {
	x := v[0]
	y := v[1]
	mut z := 0.0
	if dim == 3 {
		z = v[3]
	}
	return Point.new(x, y, z)
}

// nactive returns the number of active bins; i.e. non-nil bins
pub fn (o &Bins) nactive() int {
	mut nactive := 0
	for bin in o.all {
		if !isnil(bin) {
			nactive++
		}
	}
	return nactive
}

// nentries returns the total number of entries (in active bins)
pub fn (o &Bins) nentries() int {
	mut nentries := 0
	for bin in o.all {
		if !isnil(bin) {
			nentries += bin.entries.len
		}
	}
	return nentries
}

// summary returns the summary of this Bins' data
pub fn (o &Bins) summary() string {
	mut l := ''
	l += 'ndim        = ${o.ndim}\n'
	l += 'xmin        = ${o.xmin}\n'
	l += 'xmax        = ${o.xmax}\n'
	l += 'xdel        = ${o.xdel}\n'
	l += 'size        = ${o.size}\n'
	l += 'ndiv        = ${o.ndiv}\n'
	l += 'nall        = ${o.all.len}\n'
	l += 'nactivebins = ${o.nactive()}\n'
	l += 'nentries    = ${o.nentries()}\n'
	return l
}

// str returns the string representation of one Bin
pub fn (o Bin) str() string {
	mut l := "{\"idx\":${o.index}, \"entries\":["
	for i, entry in o.entries {
		if i > 0 {
			l += ', '
		}
		l += "{\"id\":${entry.id}, \"x\":[${entry.x[0]},${entry.x[1]}"
		if entry.x.len > 2 {
			l += ',${entry.x[2]}'
		}
		l += ']'
		if !isnil(entry.extra) {
			l += ', "extra":true'
		}
		l += '}'
	}
	l += ']}'
	return l
}

// str returns the string representation of a set of Bins
pub fn (o &Bins) str() string {
	mut l := '[\n'
	mut k := 0
	for bin in o.all {
		if !isnil(bin) {
			if k > 0 {
				l += ',\n'
			}
			l += '  ${bin}'
			k++
		}
	}
	l += '\n]'
	return l
}
