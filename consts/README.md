# Constants

The full list of constants is described briefly below.  Consult the
header files themselves for the values of the constants used in the
library.

More information is available in **[the documentation of this package](https://vsl.readthedocs.io/en/latest/consts.html).**

## Usage example

```v
module main

import vsl.consts

fn main() {
	c := consts.mksa_speed_of_light
	au := consts.mksa_astronomical_unit
	minutes := consts.mksa_minute // distance stored in meters
	r_earth := 1.0 * au
	r_mars := 1.52 * au
	t_min := (r_mars - r_earth) / c
	t_max := (r_mars + r_earth) / c
	min := t_min / minutes
	max := t_max / minutes
	println('light travel time from Earth to Mars:')
	println('minimum = $min minutes')
	println('maximum = $max minutes')
}
```

will print

```
light travel time from Earth to Mars:
minimum = 4.3 minutes
maximum = 21.0 minutes
```
