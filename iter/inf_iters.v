module iter

pub struct Counter {
pub:
	step f64
pub mut:
	state f64
}

pub fn new_count_iter(start f64, step f64) Counter {
	return Counter{
		step: step
		state: start
	}
}

pub fn (mut c Counter) next() f64 {
	s := c.state
	c.state += c.step
	return s
}

pub struct Cycler {
mut:
	idx int
pub:
	data []f64
}

pub fn new_cycle_iter(data []f64) Cycler {
	return Cycler{
		data: data
		idx: 0
	}
}

pub fn (mut c Cycler) next() f64 {
	this_idx := c.idx % c.data.len
	c.idx++
	return c.data[this_idx]
}

pub struct Repeater {
pub:
	item f64
}

pub fn new_repeat_iter(item f64) Repeater {
	return Repeater{
		item: item
	}
}

pub fn (m Repeater) next() f64 {
	return m.item
}
