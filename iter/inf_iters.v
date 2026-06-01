module iter

// Counter defines a public data structure for this module.
pub struct Counter {
pub:
	step f64
pub mut:
	state f64
}

// Counter.new exposes this operation as part of the public API.
pub fn Counter.new(start f64, step f64) Counter {
	return Counter{
		step:  step
		state: start
	}
}

// next exposes this operation as part of the public API.
pub fn (mut c Counter) next() ?f64 {
	s := c.state
	c.state += c.step
	return s
}

// Cycler defines a public data structure for this module.
pub struct Cycler {
mut:
	idx int
pub:
	data []f64
}

// Cycler.new exposes this operation as part of the public API.
pub fn Cycler.new(data []f64) Cycler {
	return Cycler{
		data: data
		idx:  0
	}
}

// next exposes this operation as part of the public API.
pub fn (mut c Cycler) next() ?f64 {
	this_idx := c.idx % c.data.len
	c.idx++
	return c.data[this_idx]
}

// Repeater defines a public data structure for this module.
pub struct Repeater {
pub:
	item f64
}

// Repeater.new exposes this operation as part of the public API.
pub fn Repeater.new(item f64) Repeater {
	return Repeater{
		item: item
	}
}

// next exposes this operation as part of the public API.
pub fn (m Repeater) next() ?f64 {
	return m.item
}
