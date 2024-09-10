module poly

import math
import vsl.errors

const radix = 2
const radix2 = (radix * radix)

// eval is a function that evaluates a polynomial P(x) = a_n * x^n + a_{n-1} * x^{n-1} + ... + a_1 * x + a_0
// using Horner's method: P(x) = (...((a_n * x + a_{n-1}) * x + a_{n-2}) * x + ... + a_1) * x + a_0
// Input: c = [a_0, a_1, ..., a_n], x
// Output: P(x)
pub fn eval(c []f64, x f64) f64 {
	if c.len == 0 {
		errors.vsl_panic('coeficients can not be empty', .efailed)
	}
	len := c.len
	mut ans := 0.0
	mut i := len - 1
	for i >= 0 {
		ans = c[i] + x * ans
		i--
	}
	return ans
}

// eval_derivs evaluates a polynomial P(x) and its derivatives P'(x), P''(x), ..., P^(k)(x)
// Input: c = [a_0, a_1, ..., a_n] representing P(x), x, and lenres (k+1)
// Output: [P(x), P'(x), P''(x), ..., P^(k)(x)]
pub fn eval_derivs(c []f64, x f64, lenres int) []f64 {
	mut res := []f64{}
	lenc := c.len
	mut i := 0
	mut n := 0
	mut nmax := 0
	for ; i < lenres; i++ {
		if n < lenc {
			res << c[lenc - 1]
			nmax = n
			n++
		} else {
			res << 0.0
		}
	}
	for i = 0; i < lenc - 1; i++ {
		k := (lenc - 1) - i
		res[0] = (x * res[0]) + c[k - 1]
		lmax := if nmax < k { nmax } else { k - 1 }
		for l := 1; l <= lmax; l++ {
			res[l] = (x * res[l]) + res[l - 1]
		}
	}
	mut f := 1.0
	for i = 2; i <= nmax; i++ {
		f *= i
		res[i] *= f
	}
	return res
}

// solve_quadratic solves the quadratic equation ax^2 + bx + c = 0
// using the quadratic formula: x = (-b ± √(b^2 - 4ac)) / (2a)
// Input: a, b, c
// Output: Array of real roots (if any)
pub fn solve_quadratic(a f64, b f64, c f64) []f64 {
	if a == 0 {
		if b == 0 {
			return []
		} else {
			return [-c / b]
		}
	}
	disc := b * b - f64(4) * a * c
	if disc > 0 {
		if b == 0 {
			r := math.sqrt(-c / a)
			return [-r, r]
		} else {
			sgnb := if b > 0 { 1 } else { -1 }
			temp := -0.5 * (b + f64(sgnb) * math.sqrt(disc))
			r1 := temp / a
			r2 := c / temp
			return if r1 < r2 { [r1, r2] } else { [r2, r1] }
		}
	} else if disc == 0 {
		return [-0.5 * b / a, -0.5 * b / a]
	} else {
		return []
	}
}

// solve_cubic solves the cubic equation x^3 + ax^2 + bx + c = 0
// using Cardano's formula and trigonometric solution
// Input: a, b, c
// Output: Array of real roots
pub fn solve_cubic(a f64, b f64, c f64) []f64 {
	q_ := (a * a - 3.0 * b)
	r_ := (2.0 * a * a * a - 9.0 * a * b + 27.0 * c)
	q := q_ / 9.0
	r := r_ / 54.0
	q3 := q * q * q
	r2 := r * r
	cr2 := 729.0 * r_ * r_
	cq3 := 2916.0 * q_ * q_ * q_
	if r == 0.0 && q == 0.0 {
		return [-a / 3.0, -a / 3.0, -a / 3.0]
	} else if cr2 == cq3 {
		sqrt_q := math.sqrt(q)
		if r > 0.0 {
			return [-2.0 * sqrt_q - a / 3.0, sqrt_q - a / 3.0, sqrt_q - a / 3.0]
		} else {
			return [-sqrt_q - a / 3.0, -sqrt_q - a / 3.0, 2.0 * sqrt_q - a / 3.0]
		}
	} else if r2 < q3 {
		sgnr := if r >= 0.0 { 1.0 } else { -1.0 }
		ratio := sgnr * math.sqrt(r2 / q3)
		theta := math.acos(ratio)
		norm := f64(-2.0 * math.sqrt(q))
		mut x0 := norm * math.cos(theta / 3.0) - a / 3.0
		mut x1 := norm * math.cos((theta + 2.0 * math.pi) / 3.0) - a / 3.0
		mut x2 := norm * math.cos((theta - 2.0 * math.pi) / 3.0) - a / 3.0
		x0, x1, x2 = sorted_3_(x0, x1, x2)
		return [x0, x1, x2]
	} else {
		sgnr := if r >= 0.0 { 1.0 } else { -1.0 }
		a_ := -sgnr * math.pow(math.abs(r) + math.sqrt(r2 - q3), 1.0 / 3.0)
		b_ := q / a_
		return [a_ + b_ - a / 3]
	}
}

// swap_ swaps two numbers: f(a, b) = (b, a)
// Input: a, b
// Output: (b, a)
@[inline]
fn swap_(a f64, b f64) (f64, f64) {
	return b, a
}

// sorted_3_ sorts three numbers in ascending order: f(x, y, z) = (min(x,y,z), median(x,y,z), max(x,y,z))
// Input: x, y, z
// Output: (min, median, max)
@[inline]
fn sorted_3_(x_ f64, y_ f64, z_ f64) (f64, f64, f64) {
	mut x := x_
	mut y := y_
	mut z := z_
	if x > y {
		x, y = swap_(x, y)
	}
	if x > z {
		x, z = swap_(x, z)
	}
	if y > z {
		y, z = swap_(y, z)
	}
	return x, y, z
}

// companion_matrix creates a companion matrix for the polynomial P(x) = a_n * x^n + a_{n-1} * x^{n-1} + ... + a_1 * x + a_0
// The companion matrix C is defined as:
// [0 0 0 ... 0 -a_0/a_n]
// [1 0 0 ... 0 -a_1/a_n]
// [0 1 0 ... 0 -a_2/a_n]
// [. . . ... . ........]
// [0 0 0 ... 1 -a_{n-1}/a_n]
// Input: a = [a_0, a_1, ..., a_n]
// Output: Companion matrix C
pub fn companion_matrix(a []f64) [][]f64 {
	nc := a.len - 1
	mut cm := [][]f64{len: nc, init: []f64{len: nc}}
	mut i := 0
	for ; i < nc; i++ {
		for j := 0; j < nc; j++ {
			cm[i][j] = 0.0
		}
	}
	for i = 1; i < nc; i++ {
		cm[i][i - 1] = 1.0
	}
	for i = 0; i < nc; i++ {
		cm[i][nc - 1] = -a[i] / a[nc]
	}
	return cm
}

// balance_companion_matrix balances a companion matrix C to improve numerical stability
// Uses an iterative scaling process to make the row and column norms as close to each other as possible
// Input: Companion matrix C
// Output: Balanced matrix B such that D^(-1)CD = B, where D is a diagonal matrix
pub fn balance_companion_matrix(cm [][]f64) [][]f64 {
	nc := cm.len
	mut m := cm.clone()
	mut not_converged := true
	mut row_norm := 0.0
	mut col_norm := 0.0
	for not_converged {
		not_converged = false
		for i := 0; i < nc; i++ {
			if i != nc - 1 {
				col_norm = math.abs(m[i + 1][i])
			} else {
				col_norm = 0.0
				for j := 0; j < nc - 1; j++ {
					col_norm += math.abs(m[j][nc - 1])
				}
			}
			if i == 0 {
				row_norm = math.abs(m[0][nc - 1])
			} else if i == nc - 1 {
				row_norm = math.abs(m[i][i - 1])
			} else {
				row_norm = (math.abs(m[i][i - 1]) + math.abs(m[i][nc - 1]))
			}
			if col_norm == 0.0 || row_norm == 0.0 {
				continue
			}
			mut g := row_norm / poly.radix
			mut f := 1.0
			s := col_norm + row_norm
			for col_norm < g {
				f *= poly.radix
				col_norm *= poly.radix2
			}
			g = row_norm * poly.radix
			for col_norm > g {
				f /= poly.radix
				col_norm /= poly.radix2
			}
			if (row_norm + col_norm) < 0.95 * s * f {
				not_converged = true
				g = 1.0 / f
				if i == 0 {
					m[0][nc - 1] *= g
				} else {
					m[i][i - 1] *= g
					m[i][nc - 1] *= g
				}
				if i == nc - 1 {
					for j := 0; j < nc; j++ {
						m[j][i] *= f
					}
				} else {
					m[i + 1][i] *= f
				}
			}
		}
	}
	return m
}

// add adds two polynomials: (a_n * x^n + ... + a_0) + (b_m * x^m + ... + b_0)
// Input: a = [a_0, ..., a_n], b = [b_0, ..., b_m]
// Output: [a_0 + b_0, a_1 + b_1, ..., max(a_k, b_k), ...]
pub fn add(a []f64, b []f64) []f64 {
	mut result := []f64{len: math.max(a.len, b.len)}
	for i in 0 .. result.len {
		result[i] = if i < a.len { a[i] } else { 0.0 } + if i < b.len { b[i] } else { 0.0 }
	}
	return result
}

// subtract subtracts two polynomials: (a_n * x^n + ... + a_0) - (b_m * x^m + ... + b_0)
// Input: a = [a_0, ..., a_n], b = [b_0, ..., b_m]
// Output: [a_0 - b_0, a_1 - b_1, ..., a_k - b_k, ...]
pub fn subtract(a []f64, b []f64) []f64 {
	mut result := []f64{len: math.max(a.len, b.len)}
	for i in 0 .. result.len {
		result[i] = if i < a.len { a[i] } else { 0.0 } - if i < b.len { b[i] } else { 0.0 }
	}
	return result
}

// multiply multiplies two polynomials: (a_n * x^n + ... + a_0) * (b_m * x^m + ... + b_0)
// Input: a = [a_0, ..., a_n], b = [b_0, ..., b_m]
// Output: [c_0, c_1, ..., c_{n+m}] where c_k = ∑_{i+j=k} a_i * b_j
pub fn multiply(a []f64, b []f64) []f64 {
	mut result := []f64{len: a.len + b.len - 1}
	for i in 0 .. a.len {
		for j in 0 .. b.len {
			result[i + j] += a[i] * b[j]
		}
	}
	return result
}

// divide divides two polynomials: (a_n * x^n + ... + a_0) / (b_m * x^m + ... + b_0)
// Uses polynomial long division algorithm
// Input: a = [a_0, ..., a_n], b = [b_0, ..., b_m]
// Output: (q, r) where q is the quotient and r is the remainder
// such that a(x) = b(x) * q(x) + r(x) and degree(r) < degree(b)
pub fn divide(a []f64, b []f64) ([]f64, []f64) {
	mut quotient := []f64{}
	mut remainder := a.clone()
	b_lead_coef := b[0]

	for remainder.len >= b.len {
		lead_coef := remainder[0] / b_lead_coef
		quotient << lead_coef
		for i in 0 .. b.len {
			remainder[i] -= lead_coef * b[i]
		}
		remainder = unsafe { remainder[1..] }
		for remainder.len > 0 && math.abs(remainder[0]) < 1e-10 {
			remainder = unsafe { remainder[1..] }
		}
	}

	if remainder.len == 0 {
		remainder = []f64{}
	}

	return quotient, remainder
}
