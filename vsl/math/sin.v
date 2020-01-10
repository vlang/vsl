// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

const (
        pi_4 = pi / 4.0
)

/**
 * Circular sin
 * 
 * Range reduction is into intervals of pi/4. The reduction
 * error is nearly eliminated by contriving an extended precision
 * modular arithmetic.
 *
 * Two polynomial approximating functions are employed:
 * 
 * Between 0 and pi/4 the sine is approximated by
 *      x  +  x**3 P(x**2).
 * 
 * Between pi/4 and pi/2 the cosine is represented as
 *      1  -  x**2 Q(x**2).
 * 
 */
pub fn sin(x_ f64) f64 {
        mut x := x_

        if x == f64(0.0) {
                return f64(0.0)
        }

        if is_nan(x) {
	        return x
        }

        if !is_finite(x) {
                return nan()
	}

        /* make argument positive but save the sign */
        mut sign := 1

        if x < 0.0 {
	        x = -x
	        sign = -1
	}

        if x > lossth {
                return 0.0
        }

        mut y := floor(x/pi_4) /* integer part of x/pi_4 */

        /* strip high bits of integer part to prevent integer overflow */
        mut z := ldexp(y, -4)
        z = floor(z)           /* integer part of y/8 */
        z = y - ldexp(z, 4)  /* y - 16 * (y/16) */

        mut j := int(z) /* convert to integer for tests on the phase angle */

        /* map zeros to origin */
        if (j & 1) == 1 {
                j++
                y += 1.0
        }
        
        j = j & 07 /* octant modulo 360 degrees */
        
        /* reflect in x axis */
        if j > 3 {
                sign = -sign
                j -= 4
        }

        /* Extended precision modular arithmetic */
        z = ((x - y * dp1) - y * dp2) - y * dp3

        zz := z * z

        if (j == 1) || (j == 2) {
                y = 1.0 - ldexp(zz, -1) + zz * zz * sinpoly(coscof, 5, zz)
        }
        else {
                y = z + z * z * z * sinpoly(sincof, 5, zz)
        }

        if sign < 0 {
                y = -y
        }

        return y
}

fn poly_eval(c []f64, x f64) f64 {
        if c.len == 0 {
                panic('coeficients can not be empty')
        }

        len := c.len
        mut ans := c[len-1]

        for e in c[..len-1] {
                ans = e + x * ans
        }

        return ans
}

// mbpoly evaluate a polynomial for the sin function
[inline]
fn sinpoly(cof []f64, n int, x f64) f64 {
	return poly_eval(cof[..n-1], x)
}
