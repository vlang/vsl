module plot

import json
import time
import vweb

// port is the port to run the server on. If 0, it will run on the next available port.
const port = 8000

struct App {
	vweb.Context
	plot Plot [vweb_global]
}

type TracesWithTypeValue = Trace | string

pub fn (p Plot) show() ! {
	$if !test ? {
		vweb.run(&App{
			plot: p
		}, plot.port)
	}
}

// TODO: This is a hack to allow the json encoder to work with sum types
fn encode[T](obj T) string {
	strings_to_replace := [
		',"[]f64"',
		'"[]f64"',
		',"[]string"',
		'"[]string"',
	]
	mut obj_json := json.encode(obj)
	for string_to_replace in strings_to_replace {
		obj_json = obj_json.replace(string_to_replace, '')
	}
	return obj_json
}

pub fn (mut app App) index() vweb.Result {
	// For some reason this is not working yet
	traces_with_type := app.plot.traces.map({
		'type':  TracesWithTypeValue(it.trace_type())
		'trace': TracesWithTypeValue(it)
	})
	traces_with_type_json := encode(traces_with_type)
	layout_json := encode(app.plot.layout)
	go fn () {
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
      
      function removeEmptyFieldsDeeply(obj) {
        if (Array.isArray(obj)) {
          return obj.map(removeEmptyFieldsDeeply);
        }
        if (typeof obj === "object") {
          const newObj = Object.fromEntries(
            Object.entries(obj)
              .map(([key, value]) => [key, removeEmptyFieldsDeeply(value)])
              .filter(([_, value]) => !!value)
          );
          return Object.keys(newObj).length > 0 ? newObj : undefined;
        }
        return obj;
      }

      const layout = ${layout_json};
      const traces_with_type_json = ${traces_with_type_json};
      const data = [...traces_with_type_json]
        .map(({ type, trace: { CommonTrace, _type, ...trace } }) => ({ type, ...CommonTrace, ...trace }));

      const payload = {
        data: removeEmptyFieldsDeeply(data),
        layout: removeEmptyFieldsDeeply(layout),
      };

      Plotly.newPlot("gd", payload);
    </script>
  </body>
</html>')
}
