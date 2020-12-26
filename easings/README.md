# Easing Functions

This is a pure V module that provides easing functions calculation.

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

## Credits

Based on the works of:

- [ScientificC/CMathL](https://github.com/ScientificC/cmathl)
- [James Tomasino](https://github.com/jamestomasino/veasing)
- [Robert Penner](http://robertpenner.com/easing/)
- [George McGinley Smith](http://gsgd.co.uk/sandbox/jquery/easing/)
- [James Padolsey](http://james.padolsey.com/demos/jquery/easing/)
- [Matt Gallagher](http://cocoawithlove.com/2008/09/parametric-acceleration-curves-in-core.html)
- [Jesse Crossen](http://stackoverflow.com/questions/5161465/how-to-create-custom-easing-function-with-core-animation)
