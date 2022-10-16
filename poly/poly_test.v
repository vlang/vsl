module poly

fn test_eval() {
	// ans = 2
	// ans = 4.0 + 4 * 2 = 12
	// ans = 5 + 4 * 12 = 53
	x := 4
	cof := [4.0, 5, 2]
	assert eval(cof, 4) == 53
}

fn test_swap() {
	mut a := 101.0
	mut b := 202.0
	a, b = swap_(a, b)
	assert a == 202.0 && b == 101.0
}

// fn test_sorted_3_(){
// 	a := 5.0
// 	b := 7.0
// 	c := -8.0
// 	x, y, z := sorted_3_(a, b, c)
// 	assert y == 7.0
// }

fn test_add() {
	a := [6.0, 777, -3]
	b := [1.0, -755, -4]
	assert add(a, b) == [7.0, 22, -7]
}

fn test_substract() {
	a := [6.0, 777, -3]
	b := [1.0, -755, -4]
	assert substract(a, b) == [5.0, 1532, 1]
}

// fn test_multiply(){
// 	a := [9.0, -1, 5]
// 	b := [0.0, -1, 7]

// 	assert multiply(a, b) == [0.0, -9, 73, -12, 35, 0]
// }
