import vsl.plot
import vsl.util
import math

f := 60.0 // Hz
a0 := 100 // V

t := util.lin_space(0, 2 * (1 / f), 100) // 2 periods
y1 := t.map(a0 * math.sin(2 * math.pi * f * it)) // y₁ = A₀·sin(2πft)
y2 := t.map(a0 * math.sin(2 * math.pi * f * it + 2 * math.pi / 3)) // y₂ = A₀·sin(2πft + 2π/3)
y3 := t.map(a0 * math.sin(2 * math.pi * f * it + 4 * math.pi / 3)) // y₃ = A₀·sin(2πft + 4π/3)

mut plt := plot.Plot.new()

plt.scatter(
	x: t
	y: y1
	name: 'y1(t)'
)

plt.scatter(
	x: t
	y: y2
	name: 'y2(t)'
)

plt.scatter(
	x: t
	y: y3
	name: 'y3(t)'
)

plt.layout(
	title: 'Three-phase system (60Hz)'
	xaxis: plot.Axis{
		title: plot.AxisTitle{'time [s]'}
	}
	yaxis: plot.Axis{
		title: plot.AxisTitle{'amplitude [V]'}
	}
)

plt.show()!
