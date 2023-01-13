module vcl

// Buffer memory buffer on the device
struct Buffer {
	size   int
	device &Device
mut:
	memobj ClMem
}

// buffer creates a new buffer with specified size
fn (d &Device) buffer(size int) ?&Buffer {
	mut ret := 0
	buffer := clCreateBuffer(d.ctx, mem_read_write, usize(size), unsafe { nil }, &ret)
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
	return vcl_error(clReleaseMemObject(b.memobj))
}

fn (b &Buffer) load(size int, ptr voidptr) chan IError {
	ch := chan IError{cap: 1}
	if b.size != size {
		ch <- error('buffer size not equal to data len')
		return ch
	}
	mut event := ClEvent(0)
	ret := clEnqueueWriteBuffer(b.device.queue, b.memobj, false, 0, usize(size), ptr,
		0, unsafe { nil }, &event)
	if ret != success {
		ch <- vcl_error(ret)
		return ch
	}
	spawn fn (event &ClEvent, ch chan IError) {
		defer {
			clReleaseEvent(event)
		}
		ch <- vcl_error(clWaitForEvents(1, event))
	}(&event, ch)

	return ch
}
