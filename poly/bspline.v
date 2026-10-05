module poly

// BSplineCurve stores a non-rational B-spline in de Boor form.
// control_points[i] is the i-th point and knots is the non-decreasing knot vector.
pub struct BSplineCurve {
pub:
	degree         int
	knots          []f64
	control_points [][]f64
}

// new_bspline_curve validates and copies the degree, knot vector, and control points.
pub fn new_bspline_curve(degree int, knots []f64, control_points [][]f64) !BSplineCurve {
	if degree < 0 {
		return error('B-spline degree must be non-negative')
	}
	if control_points.len <= degree {
		return error('B-spline needs more control points than its degree')
	}
	if knots.len != control_points.len + degree + 1 {
		return error('B-spline knot count must equal control point count + degree + 1')
	}
	validate_knot_vector(knots)!
	dimension := control_points[0].len
	if dimension == 0 {
		return error('B-spline control points must have at least one coordinate')
	}
	for point in control_points {
		if point.len != dimension {
			return error('B-spline control points must have the same dimension')
		}
	}
	return BSplineCurve{
		degree:         degree
		knots:          knots.clone()
		control_points: control_points.map(it.clone())
	}
}

// bspline_basis evaluates basis function N_{index, degree} at x using Cox-de Boor recursion.
pub fn bspline_basis(degree int, knots []f64, index int, x f64) !f64 {
	if degree < 0 {
		return error('B-spline degree must be non-negative')
	}
	if knots.len <= degree + 1 {
		return error('B-spline knot vector is too short for the degree')
	}
	validate_knot_vector(knots)!
	basis_count := knots.len - degree - 1
	if index < 0 || index >= basis_count {
		return error('B-spline basis index is outside the knot vector')
	}
	start := knots[degree]
	end := knots[basis_count]
	if x < start || x > end {
		return 0.0
	}
	if x == end {
		return if index == basis_count - 1 { 1.0 } else { 0.0 }
	}
	mut values := []f64{len: knots.len - 1}
	for i in 0 .. values.len {
		values[i] = if knots[i] <= x && x < knots[i + 1] { 1.0 } else { 0.0 }
	}
	for order in 1 .. degree + 1 {
		mut next := []f64{len: values.len - 1}
		for i in 0 .. next.len {
			left_denominator := knots[i + order] - knots[i]
			right_denominator := knots[i + order + 1] - knots[i + 1]
			left := if left_denominator == 0.0 {
				0.0
			} else {
				(x - knots[i]) / left_denominator * values[i]
			}
			right := if right_denominator == 0.0 {
				0.0
			} else {
				(knots[i + order + 1] - x) / right_denominator * values[i + 1]
			}
			next[i] = left + right
		}
		values = next.clone()
	}
	return values[index]
}

// evaluate computes a curve point at parameter u with de Boor's algorithm.
pub fn (curve BSplineCurve) evaluate(u f64) ![]f64 {
	n := curve.control_points.len - 1
	start := curve.knots[curve.degree]
	end := curve.knots[n + 1]
	if u < start || u > end {
		return error('B-spline parameter is outside the curve domain')
	}
	span := find_knot_span(curve.degree, n, curve.knots, u)
	mut points := [][]f64{cap: curve.degree + 1}
	for j in 0 .. curve.degree + 1 {
		points << curve.control_points[span - curve.degree + j].clone()
	}
	for order in 1 .. curve.degree + 1 {
		mut j := curve.degree
		for j >= order {
			i := span - curve.degree + j
			denominator := curve.knots[i + curve.degree - order + 1] - curve.knots[i]
			alpha := if denominator == 0.0 {
				0.0
			} else {
				(u - curve.knots[i]) / denominator
			}
			for dimension in 0 .. points[j].len {
				points[j][dimension] = (1.0 - alpha) * points[j - 1][dimension] + alpha * points[j][dimension]
			}
			j--
		}
	}
	return points[curve.degree]
}

// insert_knot returns a new curve with one copy of u inserted while preserving its shape.
pub fn (curve BSplineCurve) insert_knot(u f64) !BSplineCurve {
	n := curve.control_points.len - 1
	start := curve.knots[curve.degree]
	end := curve.knots[n + 1]
	if u <= start || u >= end {
		return error('B-spline knot insertion requires an interior parameter')
	}
	mut multiplicity := 0
	for knot in curve.knots {
		if knot == u {
			multiplicity++
		}
	}
	if multiplicity >= curve.degree {
		return error('B-spline knot multiplicity cannot exceed the degree')
	}
	span := find_knot_span(curve.degree, n, curve.knots, u)
	mut knots := curve.knots.clone()
	knots.insert(span + 1, u)
	mut points := [][]f64{len: n + 2}
	for i in 0 .. span - curve.degree + 1 {
		points[i] = curve.control_points[i].clone()
	}
	for i := span - multiplicity; i <= n; i++ {
		points[i + 1] = curve.control_points[i].clone()
	}
	for i := span - curve.degree + 1; i <= span - multiplicity; i++ {
		denominator := curve.knots[i + curve.degree] - curve.knots[i]
		alpha := if denominator == 0.0 { 0.0 } else { (u - curve.knots[i]) / denominator }
		points[i] = []f64{len: curve.control_points[0].len}
		for dimension in 0 .. points[i].len {
			points[i][dimension] = alpha * curve.control_points[i][dimension] + (1.0 - alpha) * curve.control_points[i - 1][dimension]
		}
	}
	return new_bspline_curve(curve.degree, knots, points)
}

fn validate_knot_vector(knots []f64) ! {
	if knots.len < 2 {
		return error('B-spline knot vector must contain at least two values')
	}
	for i in 1 .. knots.len {
		if knots[i] < knots[i - 1] {
			return error('B-spline knots must be in non-decreasing order')
		}
	}
}

fn find_knot_span(degree int, last_control_index int, knots []f64, u f64) int {
	if u == knots[last_control_index + 1] {
		return last_control_index
	}
	mut low := degree
	mut high := last_control_index + 1
	mut mid := (low + high) / 2
	for u < knots[mid] || u >= knots[mid + 1] {
		if u < knots[mid] {
			high = mid
		} else {
			low = mid
		}
		mid = (low + high) / 2
	}
	return mid
}
