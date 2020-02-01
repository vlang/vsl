// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.internal
import vsl.math

const (
        int_min = -2147483648
)

/*
 * This function uses Lanczos' expression to calculate gamma(x) for real
 * x, where -(internal.max_f64_fact_arg - 1) < x < internal.max_f64_fact_arg.
 * Note the gamma function is meromorphic in the complex plane and has
 * poles at the nonpositive integers.
 * Tests for x a positive integer or a half positive integer give a
 * maximum absolute relative error of about 1.9e-16.
 *
 * If x > internal.max_f64_fact_arg, then one should either use gamma_lanczos(x)
 * or calculate log_gamma(x).
 * Note that for x < 0, ln (gamma(x)) may be a complex number.
 *
 * @param f64 x Argument of the gamma function.
 *
 * @return f64 If x is positive and is less than internal.max_f64_fact_arg then gamma(x) is
 * returned and if x > internal.max_f64_fact_arg then internal.f64_max is returned.  If x is
 * a nonpositive integer i.e. x is a pole, then internal.f64_max is returned
 * ( note that gamma(x) changes sign on each side of the pole).  If x is
 * nonpositive nonintegral, then if gamma(x) > internal.f64_max, then internal.f64_max is
 * returned and if gamma(x) < -internal.f64_max, then -internal.f64_max is returned.
 *
 */
pub fn gamma(x f64) f64 {
        if x > internal.max_f64_fact_arg {
                return internal.f64_max
        }

        g := gamma_lanczos(x)

        if math.abs(g) < internal.f64_max {
                return g
        }

        return if g < 0.0 { -internal.f64_max } else { internal.f64_max }
}

/*
 * This function calculates the natural log of gamma(x) for positive real
 * x.
 *
 * Assuming that max_f64_fact_arg = 171, then
 * If 0 < x <= 171, then ln(gamma(x)) is calculated by taking the natural
 * log of the result from gamma(x).  If x > 171, then
 * ln(gamma(x)) is calculated using the asymptotic expansion
 *     ln(gamma(x)) ~ ln(2sqrt(2pi)) - x + (x - 1/2) ln x +
 *                    Sum B[2j] / [ 2j * (2j-1) * x^(2j-1) ], summed over
 * j from 1 to 3 and where B[2j] is the 2j-th Bernoulli number.
 *
 */
pub fn log_gamma(x f64) f64 {
        if x <= internal.max_f64_fact_arg {
                return math.log(gamma(x))
        }

        return log_gamma_asymptotic_expansion(x)
}

/*
 * This function uses Lanczos' expression to calculate gamma(x) for real
 * x, where -(max_f64_fact_arg - 1) < x < max_f64_fact_arg.
 * Note the gamma function is meromorphic in the complex plane and has
 * poles at the nonpositive integers.
 * Tests for x a positive integer or a half positive integer give a
 * maximum absolute relative error of about 3.5e-16.
 *
 * If x > max_f64_fact_arg, then one should use log_gamma(x).
 * Note that for x < 0, ln (gamma(x)) may be a complex number.
 *
 * @param f64 x Argument of the gamma function.
 *
 * @return f64 If x is positive and is less than max_f64_fact_arg, then gamma(x)
 * is returned and if x > max_f64_fact_arg, then internal.f64_max is returned.
 * If x is a nonpositive integer i.e. x is a pole, then internal.f64_max is
 * returned ( note that gamma(x) changes sign on each side of the pole).
 * If x is nonpositive nonintegral, then if x > -(max_f64_fact_arg + 1)
 * then gamma(x) is returned otherwise 0.0 is returned.
 *
 */
fn gamma_lanczos(x f64) f64 {
        if x > 0.0 {
                if x <= internal.max_f64_fact_arg {
                        return lgamma_lanczos(x)
                }
                else {
                        return internal.f64_max
                }
        }

        if (x > int_min) {
                ix := int(x)

                if (x == f64(ix))
                {
                        return internal.f64_max
                }
        }

        sin_x := math.sin(math.pi * x)

        if sin_x == 0.0 {
                return internal.f64_max
        }

        if x < -(internal.max_f64_fact_arg - 1.0) {
                return 0.0
        }

        rg := lgamma_lanczos(1.0 - x) * sin_x / math.pi

        if rg != 0.0 {
                return 1.0 / rg
        }

        return internal.f64_max
}

/*
 * This function uses Lanczos' expression to calculate gamma(x) for real
 * x, where 0 < x <= 171/2. For 171/2 < x < 171.0, the duplication formula
 * is used.
 *
 * The major source of relative error is in the use of the cml library
 * function math.pow(). The results have a relative error of about 10^-16.
 * except near x = 0.
 *
 * If x > 171.0, then one should calculate log_gamma(x).
 *
 */
fn lgamma_lanczos(x f64) f64 {
        xx := if x < 1.0 { x + 1.0 } else { x }
        n := gamma_a.len

        if x > internal.max_f64_fact_arg {
                return internal.f64_max
        }

        if x > internal.max_f64_fact_arg / 2.0 {
                return duplication_formula(x)
        }

        mut temp := 0.0
        for i := n-1; i >= 0; i-- {
                temp += (gamma_a[i] / (xx + f64(i)))
        }

        temp += 1.0
        temp *= (math.pow((g + xx - 0.5) / math.e, xx - 0.5) / exp_g_o_sqrt_2pi)

        return if x < 1.0 { temp/x } else { temp }
}

/*
 * This function returns the gamma(two_x) using the duplication formula
 * gamma(2x) = (2^(2x-1) / sqrt(pi)) gamma(x) gamma(x+1/2).
 */
fn duplication_formula(two_x f64) f64 {
        x := 0.5 * two_x
        n := int(two_x - 1)

        mut g := math.pow(2.0, two_x - 1.0 - f64(n))
        g = math.ldexp(g, n)
        g /= math.sqrt(math.pi)
        g *= gamma_lanczos(x)
        g *= gamma_lanczos(x + 0.5)

        return g
}

fn log_gamma_asymptotic_expansion(x f64) f64 {
        m := B.len
        mut term := [f64(0)].repeat(m)
        mut sum := f64(0)
        xx := x * x
        mut xj := x
        log_gamma := log_sqrt_2pi - xj + (xj - 0.5) * math.log(xj)

        for i := 0; i < m; i++ {
                term[i] = B[i] / xj
                xj *= xx
        }

        for i := m - 1; i >= 0; i-- {
                sum += term[i]
        }

        return log_gamma + sum
}
