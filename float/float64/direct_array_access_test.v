module float64

struct CapturedPanic {
mut:
	message string
}

fn capture_panic(f fn (), mut result CapturedPanic) {
	defer {
		if message := recover() {
			result.message = message
		}
	}
	f()
}

fn panic_message(f fn ()) string {
	mut result := CapturedPanic{}
	capture_panic(f, mut result)
	return result.message
}

fn test_direct_array_helpers_validate_lengths_before_indexing() {
	assert panic_message(fn () {
		mut destination := [1.0]
		axpy_unitary(1.0, [2.0, 3.0], mut destination)
	}).contains('shorter than source')
	assert panic_message(fn () {
		mut destination := [0.0]
		axpy_unitary_to(mut destination, 1.0, [2.0, 3.0], [0.0, 0.0])
	}).contains('shorter than source')
	assert panic_message(fn () {
		_ := dot_unitary([2.0, 3.0], [1.0])
	}).contains('shorter than first')
}
