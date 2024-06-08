import vsl.plot
import vsl.util
import math


f := 60.0	// Hz
beta := 0.5	// rad
a0 := 10	// V

t := util.lin_space(0, 2*(1/f), 150)	// 2 periods
y := t.map(math.sin(2*math.pi*f*it + beta))	// AC signal: y = A₀·sin(2πft + β)

mut plt := plot.Plot.new()

plt.scatter(
	x: t
	y: y
)

plt.layout(
	title: 'AC signal (60Hz)'
	xaxis: plot.Axis { 
		title: plot.AxisTitle { 'time [s]' } 
	}
	yaxis: plot.Axis { 
		title: plot.AxisTitle { 'amplitude [V]' } 
	}
)

plt.show()!