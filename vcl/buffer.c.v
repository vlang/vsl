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
	buffer := cl_create_buffer(d.ctx, mem_read_write, usize(size), unsafe { nil }, &ret)
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
	return vcl_error(cl_release_mem_object(b.memobj))
}

fn (b &Buffer) load(size int, ptr voidptr) chan IError {
	ch := chan IError{cap: 1}
	if b.size != size {
		ch <- error('buffer size not equal to data len')
		return ch
	}
	mut event := ClEvent(0)
	ret := cl_enqueue_write_buffer(b.device.queue, b.memobj, false, 0, usize(size), ptr,
		0, unsafe { nil }, &event)
	if ret != success {
		ch <- vcl_error(ret)
		return ch
	}
	spawn fn (event &ClEvent, ch chan IError) {
		defer {
			cl_release_event(event)
		}
		ch <- vcl_error(cl_wait_for_events(1, event))
	}(&event, ch)

	return ch
}
