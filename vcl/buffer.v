module vcl

// Buffer memory buffer on the device
struct Buffer {
	size   int
	device &Device
mut:
	memobj ClMem
}

// new_buffer creates a new buffer with specified size
fn new_buffer(d &Device, size int) ?&Buffer {
	mut ret := 0
	buffer := C.clCreateBuffer(d.ctx, mem_read_write, size_t(size), voidptr(0), &ret)
	if ret != success {
		return vcl_error(ret)
	}
	if isnil(buffer) {
		return err_unknown
	}
	return &Buffer{
		size: size
		device: d
		memobj: buffer
	}
}

// release releases the buffer on the device
fn (b &Buffer) release() ? {
	return vcl_error(C.clReleaseMemObject(b.memobj))
}

fn (b &Buffer) clone(size int, ptr voidptr) chan IError {
	ch := chan IError{cap: 1}
	if b.size != size {
		ch <- error('buffer size not equal to data len')
		return ch
	}
	mut event := ClEvent(0)
	ret := C.clEnqueueWriteBuffer(b.device.queue, b.memobj, false, 0, size_t(size), ptr,
		0, voidptr(0), &event)
	if ret != success {
		ch <- vcl_error(ret)
		return ch
	}
	// go func(mut event ClEvent, ch chan IError) {
	// 	defer { C.clReleaseEvent(event) }
	// 	ch <- vcl_error(C.clWaitForEvents(1, &event))
	// }(mut event, ch)

	return ch
}
