module plot

import json
import time
import vweb

const port = 8082

struct App {
	vweb.Context
	plot Plot [vweb_global]
}

pub fn (mut app App) index() vweb.Result {
	// For some reason this is not working yet
	data := json.encode_pretty(app.plot.traces)
	layout := json.encode_pretty(app.plot.layout)
	spawn fn () {
		time.sleep(100 * time.millisecond)
		exit(0)
	}()
	return app.html('<!DOCTYPE html>
<html>
  <head>
    <title>VSL Plot</title>
  </head>
  <body>
    <div id="gd"></div>

    <script type="module">
      import "https://cdn.plot.ly/plotly-2.26.2.min.js";
      const data = ${data};
      const layout = ${layout};
      Plotly.newPlot("gd", {
        data,
        layout,
      });
    </script>
  </body>
</html>')
}

pub fn (p Plot) show() ! {
	$if !test ? {
		vweb.run(&App{
			plot: p
		}, plot.port)
	}
}
