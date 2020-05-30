# Easings

This is a pure V module that provides easing function calculations.

More information is available in **[the documentation of this package](https://vsl.readthedocs.io/en/latest/easings.html).**


## Usage

Use the `animate` function to apply an easing function over a range of numbers

```v
module main

import vsl.easings

fn main () {
  println(easings.animate(easings.bounce_ease_out, 0, 100, 100))
  //      easing function ^
  //                                  lower bounds ^
  //                                     upper bounds ^
  //               number of frames/length of return array ^
}
```

The following easing methods are available:

```v
easings.linear_interpolation(p f64) f64

easings.quadratic_ease_in(p f64) f64
easings.quadratic_ease_out(p f64) f64
easings.quadratic_ease_in_out(p f64) f64

easings.cubic_ease_in(p f64) f64
easings.cubic_ease_out(p f64) f64
easings.cubic_ease_in_out(p f64) f64

easings.quartic_ease_in(p f64) f64
easings.quartic_ease_out(p f64) f64
easings.quartic_ease_in_out(p f64) f64

easings.quintic_ease_in(p f64) f64
easings.quintic_ease_out(p f64) f64
easings.quintic_ease_in_out(p f64) f64

easings.sine_ease_in(p f64) f64
easings.sine_ease_out(p f64) f64
easings.sine_ease_in_out(p f64) f64

easings.circular_ease_in(p f64) f64
easings.circular_ease_out(p f64) f64
easings.circular_ease_in_out(p f64) f64

easings.exponential_ease_in(p f64) f64
easings.exponential_ease_out(p f64) f64
easings.exponential_ease_in_out(p f64) f64

easings.elastic_ease_in(p f64) f64
easings.elastic_ease_out(p f64) f64
easings.elastic_ease_in_out(p f64) f64

easings.back_ease_in(p f64) f64
easings.back_ease_out(p f64) f64
easings.back_ease_in_out(p f64) f64

easings.bounce_ease_in(p f64) f64
easings.bounce_ease_out(p f64) f64
easings.bounce_ease_in_out(p f64) f64
```

## Credits

Based on the works of:

- [ScientificC/CmathL](https://github.com/ScientificC/cmathl)
- [James Tomasino](https://github.com/jamestomasino/veasing)
- [Robert Penner](http://robertpenner.com/easing/)
- [George McGinley Smith](http://gsgd.co.uk/sandbox/jquery/easing/)
- [James Padolsey](http://james.padolsey.com/demos/jquery/easing/)
- [Matt Gallagher](http://cocoawithlove.com/2008/09/parametric-acceleration-curves-in-core.html)
- [Jesse Crossen](http://stackoverflow.com/questions/5161465/how-to-create-custom-easing-function-with-core-animation)
