module vcl

pub interface ArgumentType {}

// kernel returns a kernel
// if retrieving the kernel didn't complete the function will return an error
pub fn (d &Device) kernel(name string) !&Kernel {
	mut k := ClKernel(0)
	mut ret := 0
	for p in d.programs {
		k = cl_create_kernel(p, &char(name.str), &ret)
		if ret == invalid_kernel_name {
			continue
		}
		if ret != success {
			return error_from_code(ret)
		}
		break
	}
	if ret == invalid_kernel_name {
		return error("kernel with name '${name}' not found")
	}
	return &Kernel{
		d: d
		k: k
	}
}

pub struct UnsupportedArgumentTypeError {
	Error
pub:
	index int
	value ArgumentType
}

pub fn (err UnsupportedArgumentTypeError) msg() string {
	return 'cl: unsupported argument type for index ${err.index}: ${err.value}'
}

fn UnsupportedArgumentTypeError.new(index int, value ArgumentType) IError {
	return UnsupportedArgumentTypeError{
		index: index
		value: value
	}
}

// Kernel represent a single kernel
pub struct Kernel {
	d &Device = unsafe { nil }
	k ClKernel
}

// global returns an kernel with global size set
pub fn (k &Kernel) global(global_work_sizes ...int) KernelWithGlobal {
	return KernelWithGlobal{
		kernel:            unsafe { k }
		global_work_sizes: global_work_sizes
	}
}

// KernelWithGlobal is a kernel with the global size set
// to run the kernel it must also set the local size
pub struct KernelWithGlobal {
	kernel            &Kernel = unsafe { nil }
	global_work_sizes []int
}

// local ets the local work sizes and returns an KernelCall which takes kernel arguments and runs the kernel
pub fn (kg KernelWithGlobal) local(local_work_sizes ...int) KernelCall {
	return KernelCall{
		kernel:            kg.kernel
		global_work_sizes: kg.global_work_sizes
		local_work_sizes:  local_work_sizes
	}
}

// KernelCall is a kernel with global and local work sizes set
// and it's ready to be run
pub struct KernelCall {
	kernel            &Kernel = unsafe { nil }
	global_work_sizes []int
	local_work_sizes  []int
}

// run calls the kernel on its device with specified global and local work sizes and arguments
// it's a non-blocking call, so it returns a channel that will send an error value when the kernel is done
// or nil if the call was successful
pub fn (kc KernelCall) run(args ...ArgumentType) chan IError {
	ch := chan IError{cap: 1}
	kc.kernel.set_args(...args) or {
		ch <- err
		return ch
	}
	return kc.kernel.call(kc.global_work_sizes, kc.local_work_sizes)
}

fn release_kernel(k &Kernel) {
	cl_release_kernel(k.k)
}

fn (k &Kernel) set_args(args ...ArgumentType) ! {
	for i, arg in args {
		k.set_arg(i, arg)!
	}
}

fn (k &Kernel) set_arg(index int, arg ArgumentType) ! {
	match arg {
		u8 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		i8 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		u16 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		i16 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		int {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		u32 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		i32 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		u64 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		i64 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		f32 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		f64 {
			return k.set_arg_unsafe(index, int(sizeof(*arg)), *arg)
		}
		Buffer {
			return k.set_arg_buffer(index, arg)
		}
		Bytes {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[byte] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[f32] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[f64] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[i16] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[i64] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[i8] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[int] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[u16] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[u32] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Vector[u64] {
			return k.set_arg_buffer(index, arg.buf)
		}
		Image {
			return k.set_arg_buffer(index, arg.buf)
		}
		else {
			return UnsupportedArgumentTypeError.new(index, arg)
		}
	}
}

fn (k &Kernel) set_arg_buffer(index int, buf &Buffer) ! {
	mem := buf.memobj
	return k.set_arg_unsafe(index, int(sizeof(mem)), &mem)
}

fn (k &Kernel) set_arg_local(index int, size int) ! {
	return k.set_arg_unsafe(index, size, unsafe { nil })
}

fn (k &Kernel) set_arg_unsafe(index int, arg_size int, arg voidptr) ! {
	res := cl_set_kernel_arg(k.k, u32(index), usize(arg_size), arg)
	if res != success {
		return vcl_error(res)
	}
}

fn (k &Kernel) call(work_sizes []int, lokal_sizes []int) chan IError {
	ch := chan IError{cap: 1}
	work_dim := work_sizes.len
	if work_dim != lokal_sizes.len {
		ch <- error('length of work_sizes and localSizes differ')
		return ch
	}
	mut global_work_offset_ptr := []usize{len: work_dim}
	mut global_work_size_ptr := []usize{len: work_dim}
	for i in 0 .. work_dim {
		global_work_size_ptr[i] = usize(work_sizes[i])
	}
	mut local_work_size_ptr := []usize{len: work_dim}
	for i in 0 .. work_dim {
		local_work_size_ptr[i] = usize(lokal_sizes[i])
	}
	mut event := ClEvent(0)
	res := cl_enqueue_nd_range_kernel(k.d.queue, k.k, u32(work_dim), unsafe { &global_work_offset_ptr[0] },
		unsafe { &global_work_size_ptr[0] }, unsafe { &local_work_size_ptr[0] }, 0, unsafe { nil },
		unsafe { &event })
	if res != success {
		err := error_from_code(res)
		ch <- err
		return ch
	}
	go fn (ch chan IError, event ClEvent) {
		defer {
			cl_release_event(event)
		}
		res := cl_wait_for_events(1, unsafe { &event })
		ch <- error_from_code(res)
	}(ch, event)
	return ch
}
