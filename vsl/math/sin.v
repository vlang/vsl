// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

const (
        sincof = [
            f64(1.58962301576546568060e-10),
                -2.50507477628578072866e-8,
                2.75573136213857245213e-6,
                -1.98412698295895385996e-4,
                8.33333333332211858878e-3,
                -1.66666666666666307295e-1
        ]

        coscof = [
            f64(-1.13585365213876817300e-11),
                2.08757008419747316778e-9,
                -2.75573141792967388112e-7,
                2.48015872888517045348e-5,
                -1.38888888888730564116e-3,
                4.16666666666665929218e-2,
        ]

        dp1 =   7.85398125648498535156e-1
        dp2 =   3.77489470793079817668e-8
        dp3 =   2.69515142907905952645e-15

        lossth = 1.073741824e+9

        pi_4 = pi / 4.0
)

/**
 * Circular cosine
 * 
 * Range reduction is into intervals of pi/4. The reduction
 * error is nearly eliminated by contriving an extended precision
 * modular arithmetic.
 *
 * Two polynomial approximating functions are employed:
 * 
 * Between 0 and pi/4 the cosine is approximated by
 *      1  -  x**2 Q(x**2).
 * 
 * Between pi/4 and pi/2 the sine is represented as
 *      x  +  x**3 P(x**2).
 * 
 */
pub fn cos(x_ f64) f64 {
        mut x := x_

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
	}

        if x > lossth {
                return 0.0
        }

        mut y := floor(x/pi_4) /* integer part of x/pi_4 */

        /* strip high bits of integer part to prevent integer overflow */
        mut z := ldexp(y, -4)
        z = floor(z)           /* integer part of y/8 */
        z = y - ldexp(z, 4)  /* y - 16 * (y/16) */

        mut i := int(z) /* convert to integer for tests on the phase angle */

        /* map zeros to origin */
        if (i & 1) == 1 {
                i++
                y += 1.0
        }
        
        mut j := i & 07 /* octant modulo 360 degrees */
        
        /* reflect in x axis */
        if j > 3 {
                sign = -sign
                j -= 4
        }

        if j > 1 {
                sign = -sign
        }

        /* Extended precision modular arithmetic */
        z = ((x - y * dp1) - y * dp2) - y * dp3

        zz := z * z

        if (j == 1) || (j == 2) {
                y = z + z * z * z * sinpoly(sincof, 5, zz)
        }
        else {
                y = 1.0 - ldexp(zz, -1) + zz * zz * sinpoly(coscof, 5, zz)
        }

        if sign < 0 {
                y = -y
        }

        return y
}

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
