module iter

pub struct Counter {
pub:
	step f64
pub mut:
	state f64
}

pub fn new_counter_iter(start f64, step f64) Counter {
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
