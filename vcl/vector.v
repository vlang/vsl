module vcl

// Vector is a memory buffer on device that holds []f32
pub struct Vector {
mut:
	buf &Buffer
}

// new_vector allocates new vector buffer with specified length
pub fn (d &Device) new_vector(length int) ?&Vector {
	size := length * int(sizeof(f32))
	buf := new_buffer(d, size) ?
	return &Vector{
		buf: &Buffer{
			memobj: buf.memobj
			device: d
			size: size
		}
	}
}

// Length the length of the vector
pub fn (v &Vector) length() int {
	return v.buf.size / int(sizeof(f32))
}

// Release releases the buffer on the device
pub fn (v &Vector) release() ? {
	return v.buf.release()
}

// clone copies the T data from host data to device buffer
// it's a non-blocking call, channel will return an error or nil if the data transfer is complete
pub fn (mut v Vector) clone(data []f32) chan IError {
	if v.length() != data.len {
		ch := chan IError{cap: 1}
		ch <- error('vector length not equal to data length')
		return ch
	}
	return v.buf.clone(data.len * int(sizeof(f32)), unsafe { &data[0] })
}

// data gets T data from device, it's a blocking call
pub fn (v &Vector) data() ?[]f32 {
	mut data := []f32{len: int(v.buf.size / 4)}
	ret := C.clEnqueueReadBuffer(v.buf.device.queue, v.buf.memobj, true, 0, v.buf.size,
		unsafe { &data[0] }, 0, voidptr(0), voidptr(0))
	if ret != success {
		return vcl_error(ret)
	}
	return data
}

// map applies an map kernel on all elements of the vector
pub fn (v &Vector) map(k &Kernel) chan IError {
	return k.global(v.length()).local(1).run(v)
}
