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
	mut hist := Histogram.new(util.lin_space(xmin, xmax, nstations))
	hist.count(values, true)!
	labels := hist.gen_labels(numfmt)!
	return text_hist(labels, hist.counts, barlen)
}

/**
 * Histogram holds data for computing/plotting histograms
 *
 *  Bins are left-closed and right-open, except the last bin includes its
 *  right edge, matching NumPy histogram boundary semantics.
 *
 *       [ bin[0] )[ bin[1] )[ bin[2] )[ bin[3] )[ bin[4] ]
 *    ---|---------|---------|---------|---------|---------|---  x
 *     s[0]      s[1]      s[2]      s[3]      s[4]      s[5]
 *
*/
// Histogram defines a public data structure for this module.
pub struct Histogram {
pub mut:
	stations []f64 // stations
	counts   []int // counts
}

// Histogram.new returns an histogram struct from a given list of stations
pub fn Histogram.new(stations []f64) &Histogram {
	return &Histogram{
		stations: stations
	}
}

fn (o Histogram) validate_stations() ! {
	if o.stations.len < 2 {
		return errors.error('Histogram must have at least 2 stations', .efailed)
	}
	for i, edge in o.stations {
		if math.is_nan(edge) || math.is_inf(edge, 0) {
			return errors.error('Histogram stations must all be finite', .efailed)
		}
		if i > 0 && edge <= o.stations[i - 1] {
			return errors.error('Histogram stations must be strictly increasing', .efailed)
		}
	}
}

// find_bin finds where x falls in
// returns -1 if x is outside the range
pub fn (o Histogram) find_bin(x f64) !int {
	o.validate_stations()!
	if math.is_nan(x) {
		return errors.error('Histogram cannot assign NaN to a bin', .efailed)
	}
	return o.find_bin_unchecked(x)
}

fn (o Histogram) find_bin_unchecked(x f64) int {
	nbins := o.stations.len - 1
	if x < o.stations[0] {
		return -1
	}
	if x > o.stations[o.stations.len - 1] {
		return -1
	}
	if x == o.stations[o.stations.len - 1] {
		return nbins - 1
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
	o.validate_stations()!
	for x in vals {
		if math.is_nan(x) {
			return errors.error('Histogram cannot assign NaN to a bin', .efailed)
		}
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
		idx := o.find_bin_unchecked(x)
		if idx >= 0 {
			o.counts[idx]++
		}
	}
}

// gen_labels generate nice labels identifying bins
pub fn (o Histogram) gen_labels(numfmt string) ![]string {
	o.validate_stations()!
	nbins := o.stations.len - 1
	mut labels := []string{len: nbins}
	for i in 0 .. nbins {
		right := if i == nbins - 1 { ']' } else { ')' }
		labels[i] = unsafe { strconv.v_sprintf('[${numfmt},${numfmt}${right}', o.stations[i], o.stations[i + 1]) }
	}
	return labels
}

// density returns per-bin probability densities using each bin's actual width.
// `nsamples` is the total number of observations, including those outside the
// histogram range; therefore the integrated density is the in-range fraction.
pub fn (o Histogram) density(nsamples int) ![]f64 {
	o.validate_stations()!
	if nsamples <= 0 {
		return errors.error('histogram density needs a positive sample count', .efailed)
	}
	nbins := o.stations.len - 1
	if o.counts.len != nbins {
		return errors.error('histogram density requires counts for every bin', .efailed)
	}
	mut densities := []f64{len: nbins}
	for i in 0 .. nbins {
		width := o.stations[i + 1] - o.stations[i]
		if math.is_inf(width, 0) || width <= 0 {
			return errors.error('histogram bin widths must be finite and positive', .efailed)
		}
		densities[i] = f64(o.counts[i]) / f64(nsamples) / width
	}
	return densities
}

// density_area integrates per-bin densities over the histogram range.
pub fn (o Histogram) density_area(nsamples int) !f64 {
	densities := o.density(nsamples)!
	mut area := 0.0
	for i, density in densities {
		width := o.stations[i + 1] - o.stations[i]
		area += density * width
	}
	return area
}
