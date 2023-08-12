module dist

import math
import strconv
import vsl.errors
import vsl.util

// text_hist prints a text histogram
pub fn text_hist(labels []string, counts []int, barlen int) !string {
	// check
	assert labels.len == counts.len
	if counts.len < 2 {
		return errors.error('counts slice is too short', .efailed)
	}
	// scale
	mut fmax := counts[0]
	mut lmax := 0
	mut lmax_ := 0
	for i, f in counts {
		fmax = math.max(fmax, f)
		lmax = math.max(lmax, labels[i].len)
		lmax_ = math.max(lmax_, f.str().len)
	}
	if fmax < 1 {
		return 'max frequency is too small: fmax=${fmax}'
	}
	scale := f64(barlen) / f64(fmax)
	// print
	mut sz := (lmax + 1).str()
	mut sz_ := (lmax_ + 1).str()
	mut l := ''
	mut total := 0
	for i, f in counts {
		l += unsafe { strconv.v_sprintf('%${sz}s | %${sz_}d ', labels[i], f) }
		mut n := int(f64(f) * scale)
		if f > 0 { // TODO: improve this
			n++
		}
		for _ in 0 .. n {
			l + '#'
		}
		l += '\n'
		total += f
	}
	sz = (lmax + 3).str()
	count := 'count ='
	l += unsafe { strconv.v_sprintf('%${sz}s %${sz_}d\n', count, total) }
	return l
}

// build_text_hist builds a text histogram
pub fn build_text_hist(xmin f64, xmax f64, nstations int, values []f64, numfmt string, barlen int) !string {
	mut hist := new_histogram(util.lin_space(xmin, xmax, nstations))
	hist.count(values, true)!
	labels := hist.gen_labels(numfmt)!
	return text_hist(labels, hist.counts, barlen)
}

/**
 * Histogram holds data for computing/plotting histograms
 *
 *  bin[i] corresponds to station[i] <= x < station[i+1]
 *
 *       [ bin[0] )[ bin[1] )[ bin[2] )[ bin[3] )[ bin[4] )
 *    ---|---------|---------|---------|---------|---------|---  x
 *     s[0]      s[1]      s[2]      s[3]      s[4]      s[5]
 *
*/
pub struct Histogram {
pub mut:
	stations []f64 // stations
	counts   []int // counts
}

// new_histogram returns an histogram struct from a given list of stations
pub fn new_histogram(stations []f64) &Histogram {
	return &Histogram{
		stations: stations
	}
}

// find_bin finds where x falls in
// returns -1 if x is outside the range
pub fn (o Histogram) find_bin(x f64) !int {
	// check
	if o.stations.len < 2 {
		return errors.error('Histogram must have at least 2 stations', .efailed)
	}
	if x < o.stations[0] {
		return -1
	}
	if x >= o.stations[o.stations.len - 1] {
		return -1
	}
	// perform binary search
	mut upper := o.stations.len
	mut lower := 0
	mut mid := 0
	for upper - lower > 1 {
		mid = (upper + lower) / 2
		if x >= o.stations[mid] {
			lower = mid
		} else {
			upper = mid
		}
	}
	return lower
}

// count counts how many items fall within each bin
pub fn (mut o Histogram) count(vals []f64, clear bool) ! {
	// check
	if o.stations.len < 2 {
		return errors.error('Histogram must have at least 2 stations', .efailed)
	}
	// allocate/clear counts
	nbins := o.stations.len - 1
	if o.counts.len != nbins {
		o.counts = []int{len: nbins}
	} else if clear {
		for i := 0; i < nbins; i++ {
			o.counts[i] = 0
		}
	}
	// add entries to bins
	for x in vals {
		idx := o.find_bin(x)!
		if idx >= 0 {
			o.counts[idx]++
		}
	}
}

// gen_labels generate nice labels identifying bins
pub fn (o Histogram) gen_labels(numfmt string) ![]string {
	if o.stations.len < 2 {
		return errors.error('Histogram must have at least 2 stations', .efailed)
	}
	nbins := o.stations.len - 1
	mut labels := []string{len: nbins}
	for i in 0 .. nbins {
		labels[i] = unsafe {
			strconv.v_sprintf('[${numfmt},${numfmt})', o.stations[i], o.stations[i + 1])
		}
	}
	return labels
}

// density_area computes the area of the density diagram
//  nsamples -- number of samples used when generating pseudo-random numbers
pub fn (o Histogram) density_area(nsamples int) !f64 {
	nstations := o.stations.len
	if nstations < 2 {
		return errors.error('density area computation needs at least two stations', .efailed)
	}
	dx := (o.stations[nstations - 1] - o.stations[0]) / f64(nstations - 1)
	mut prob := []f64{len: nstations}
	for i in 0 .. nstations - 1 {
		prob[i] = f64(o.counts[i]) / (f64(nsamples) * dx)
	}
	mut area := 0.0
	for i in 0 .. nstations - 1 {
		area += dx * prob[i]
	}
	return area
}
