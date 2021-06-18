module vcl

// Buffer memory buffer on the device
struct Buffer {
	size   int
	device &Device
mut:
	memobj C.cl_mem
}

// new_buffer creates a new buffer with specified size
fn new_buffer(d &Device, size int) ?&Buffer {
	mut ret := 0
	cl_buffer := C.clCreateBuffer(d.ctx, C.CL_MEM_READ_WRITE, C.size_t(size), voidptr(0),
		&ret)
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	if isnil(cl_buffer) {
		return err_unknown
	}
	return &Buffer{
		size: size
		device: d
		memobj: cl_buffer
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
	mut event := C.cl_event{}
	ret := C.clEnqueueWriteBuffer(b.device.queue, b.memobj, C.CL_FALSE, 0, C.size_t(size),
		ptr, 0, voidptr(0), &event)
	if ret != C.CL_SUCCESS {
		ch <- vcl_error(ret)
		return ch
	}
	// go func(mut event C.cl_event, ch chan IError) {
	// 	defer { C.clReleaseEvent(event) }
	// 	ch <- vcl_error(C.clWaitForEvents(1, &event))
	// }(mut event, ch)

	return ch
}
