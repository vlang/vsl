module vcl

// Bytes is a memory buffer on the device that holds []byte
pub struct Bytes {
	buf &Buffer
}

// bytes allocates new memory buffer with specified size on device
pub fn (d &Device) bytes(size int) ?&Bytes {
	buf := d.buffer(size)?
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

// load copies the data from host data to device buffer
// it's a non-blocking call, channel will return an error or nil if the data transfer is complete
pub fn (b &Bytes) load(data []byte) chan IError {
	return b.buf.load(data.len, unsafe { &data[0] })
}

// data gets data from device, it's a blocking call
pub fn (b &Bytes) data() ?[]u8 {
	mut data := []u8{len: b.buf.size}
	ret := clEnqueueReadBuffer(b.buf.device.queue, b.buf.memobj, true, 0, usize(b.buf.size),
		unsafe { &data[0] }, 0, unsafe { nil }, unsafe { nil })
	if ret != success {
		return vcl_error(ret)
	}
	return data
}

// map applies an map kernel on all elements of the buffer
pub fn (b &Bytes) map(mut k Kernel) chan IError {
	return k.global(b.buf.size).local(1).run(b)
}
