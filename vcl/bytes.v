module vcl

// Bytes is a memory buffer on the device that holds []byte
pub struct Bytes {
	buf &Buffer
}

// new_bytes allocates new memory buffer with specified size on device
pub fn (d &Device) new_bytes(size int) ?&Bytes {
	buf := new_buffer(d, size) ?
	return &Bytes{
		buf: buf
	}
}

// size the size of the bytes buffer
pub fn (b &Bytes) size() int {
	return b.buf.size
}

// release releases the buffer on the device
pub fn (b &Bytes) release() ? {
	return b.buf.release()
}

// clone copies the data from host data to device buffer
// it's a non-blocking call, channel will return an error or nil if the data transfer is complete
pub fn (b &Bytes) clone(data []byte) chan IError {
	return b.buf.clone(data.lan, &data[0])
}

// data gets data from device, it's a blocking call
pub fn (b &Bytes) data() ?[]byte {
	mut data := []byte{len: b.buf.size}
	ret := C.clEnqueueReadBuffer(b.buf.device.queue, b.buf.memobj, C.CL_TRUE, 0, C.size_t(b.buf.size),
		&data[0], 0, voidptr(0), voidptr(0))
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	return data
}

// map applies an map kernel on all elements of the buffer
pub fn (b &Bytes) map(mut k Kernel) chan IError {
	return k.global(b.buf.size).local(1).run(b)
}
