module plot

import json
import net
import net.html
import net.http
import os
import time

// PlotConfig is a configuration for the Plotly plot.
[params]
pub struct PlotConfig {
	use_cdn bool
}

// show starts a web server and opens a browser window to display the plot.
pub fn (p Plot) show(config PlotConfig) ! {
	$if test ? {
		println('Ignoring plot.show() because we are running in test mode')
	} $else {
		mut handler := PlotlyHandler{
			use_cdn: true
			plot: p
		}
		listener := net.listen_tcp(net.AddrFamily.ip, ':0')!
		mut server := &http.Server{
			accept_timeout: 1 * time.second
			listener: listener
			handler: handler
		}
		handler.server = server
		t := spawn server.listen_and_serve()
		server.wait_till_running()!
		os.open_uri('http://${server.addr}')!
		t.wait()
	}
}

// Plot is a plotly plot.
type TracesWithTypeValue = Trace | string

// PlotlyScriptConfig is a configuration for the Plotly plot script.
[params]
pub struct PlotlyScriptConfig {
	PlotConfig
}

// get_plotly_script returns the plot script as an html tag.
pub fn (p Plot) get_plotly_script(element_id string, config PlotlyScriptConfig) &html.Tag {
	traces_with_type := p.traces.map({
		'type':  TracesWithTypeValue(it.trace_type())
		'trace': TracesWithTypeValue(it)
	})
	traces_with_type_json := encode(traces_with_type)
	layout_json := encode(p.layout)

	plot_script := &html.Tag{
		name: 'script'
		attributes: {
			'type': 'module'
		}
		content: 'import "https://cdn.plot.ly/plotly-2.26.2.min.js";

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

Plotly.newPlot("${element_id}", payload);'
	}

	return plot_script
}

fn (p Plot) get_html(element_id string, config PlotConfig) string {
	title := if p.layout.title == '' { 'VSL Plot' } else { p.layout.title }
	plot_script := p.get_plotly_script(element_id, use_cdn: config.use_cdn)

	return '<!DOCTYPE html>
<html>
  <head>
    <title>${title}</title>
  </head>
  <body>
    <div id="${element_id}"></div>

    ${*plot_script}
  </body>
</html>'
}

struct PlotlyHandler {
	PlotlyScriptConfig
	plot Plot
mut:
	server &http.Server [str: skip] = unsafe { nil }
}

fn (mut handler PlotlyHandler) handle(req http.Request) http.Response {
	mut r := http.Response{
		body: handler.plot.get_html('gd', use_cdn: handler.use_cdn)
		header: req.header
	}
	r.set_status(.ok)
	r.set_version(req.version)
	go fn [mut handler] () {
		time.sleep(300 * time.millisecond)
		handler.server.close()
	}()
	return r
}

// TODO: This is a hack to allow the json encoder to work with sum types
fn encode[T](obj T) string {
	strings_to_replace := [
		',"[]f64"',
		'"[]f64"',
		',"[][]f64"',
		'"[][]f64"',
		',"[]int"',
		'"[]int"',
		',"[]string"',
		'"[]string"',
	]
	mut obj_json := json.encode(obj)
	for string_to_replace in strings_to_replace {
		obj_json = obj_json.replace(string_to_replace, '')
	}
	return obj_json
}
