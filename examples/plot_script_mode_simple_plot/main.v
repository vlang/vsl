import vsl.plot
import vsl.util
import math

t := util.lin_space(-math.pi, math.pi, 50)
y := []f64{len: t.len, init: math.sin(t[index])}

mut plt := plot.Plot.new()

plt.scatter(
	x: t
	y: y
)

plt.show()!
