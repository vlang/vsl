module vcl

// Vector is a memory buffer on device that holds []T
pub struct Vector<T> {
mut:
	buf &Buffer
}

// new_vector allocates new vector buffer with specified length
pub fn (d &Device) new_vector<T>(length int) ?&Vector {
	size := length * sizeof(T)
	buf := new_buffer(d, size) ?
	return &Vector<T>{
		buf: &Buffer{
			memobj: buf
			device: d
			size: size
		}
	}
}

// copy copies the T data from host data to device buffer
// it's a non-blocking call, channel will return an error or nil if the data transfer is complete
pub fn (mut v Vector<T>) copy<T>(data []T) chan IError {
	if v.length() != data.len {
		ch := chan IError{cap: 1}
		ch <- error('vector length not equal to data length')
		return ch
	}
	return v.buf.copy(data.len * sizeof(T), unsafe { &data[0] })
}

// data gets T data from device, it's a blocking call
pub fn (v &Vector<T>) data<T>() ?[]T {
	mut data := []T{len: int(v.buf.size / 4)}
	ret := C.clEnqueueReadBuffer(v.buf.device.queue, v.buf.memobj, true, 0, v.buf.size,
		unsafe { &data[0] }, 0, voidptr(0), voidptr(0))
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	return data
}

// map applies an map kernel on all elements of the vector
pub fn (v &Vector) map(k &Kernel) chan IError {
	return k.global(v.length()).local(1).run(v)
}
