module ml

import vsl.vmath as math
import vsl.la

// LogReg implements a logistic regression model (Observer of Data)
pub struct LogReg {
mut:
	// main
        name   string // name of this "observer"
	data   &Data // x-y data
	params &ParamsReg // parameters: θ, b, λ
	stat   &Stat // statistics
	// workspace
	ybar      []f64 // bar{y}: yb[i] = (1 - y[i]) / m
        l         []f64 // vector l = b⋅o + X⋅θ [nb_samples]
	hmy       []f64 // vector e = h(l) - y [nb_samples]
}

// new_log_reg returns a new LogReg object
//   Input:
//     data   -- x,y data
//     params -- θ, b, λ
//     name   -- unique name of this (observer) object
pub fn new_log_reg(mut data Data, params &ParamsReg, name string) LogReg {
	mut stat := stat_from_data(mut data, "stat_" + name)
	stat.update()
	mut log_reg := LogReg{
                name: name
		data: data
		params: params
		stat: &stat
		ybar: []f64{len: data.nb_samples}
                l: []f64{len: data.nb_samples}
                hmy: []f64{len: data.nb_samples}
	}
        data.add_observer(log_reg) // need to recompute yb upon changes on y
        log_reg.update() // compute first ybar
        return log_reg
}

// name returns the name of this LogReg object (thus defining the Observer interface)
pub fn (o LogReg) name() string {
	return o.name
}

// Update perform updates after data has been changed (as an Observer)
pub fn (mut o LogReg) update() {
        m_1 := 1.0 / f64(o.data.nb_samples)
        for i in 0 .. o.data.nb_samples {
                o.ybar[i] = (1.0 - o.data.y[i]) * m_1
        }
}
