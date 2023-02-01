module vcl

// Rect is a struct that represents a rectangle shape
[params]
pub struct Rect {
pub:
	x      f32
	y      f32
	width  f32
	height f32
}

// ImageData holds the fileds and data needed to represent a bitmap/pixel based image in memory.
[params]
pub struct ImageData {
pub mut:
	id          int
	width       int
	height      int
	nr_channels int
	data        voidptr
	ext         string
	path        string
}

// Image memory buffer on the device with image data
pub struct Image {
	format ClImageFormat
	desc   &ClImageDesc
	_data voidptr
mut:
	buf &Buffer
pub:
	@type  ImageChannelOrder
	bounds Rect
}

// release releases the buffer on the device
pub fn (mut img Image) release() ? {
	return img.buf.release()
}

// image allocates an image buffer
pub fn (d &Device) image(@type ImageChannelOrder, bounds Rect) ?&Image {
	println(@STRUCT + '.' + @FN + ' is not stable yet. Issues are expected.')
	return d.create_image(@type, bounds, 0, unsafe { nil })
}

// from_image creates new Image and copies data from Image
pub fn (d &Device) from_image(img ImageData) ?&Image {
	println(@STRUCT + '.' + @FN + ' is not stable yet. Issues are expected.')
	data := img.data
	mut row_pitch := 0
	mut image_type := ImageChannelOrder.intensity

	if img.nr_channels in [3, 4] {
		image_type = ImageChannelOrder.rgba
	}

	bounds := Rect{0, 0, img.width, img.height}
	return d.create_image(image_type, bounds, row_pitch, data)
}

// create_image creates a new image
fn (d &Device) create_image(image_type ImageChannelOrder, bounds Rect, row_pitch int, data voidptr) ?&Image {
	format := C.create_image_format(usize(image_type), usize(ImageChannelDataType.unorm_int8))
	desc := C.create_image_desc(C.CL_MEM_OBJECT_IMAGE2D, usize(bounds.width), usize(bounds.height),
		0, 0, usize(row_pitch), 0, 0, 0, unsafe { nil })

	mut flags := mem_read_write

	if !isnil(data) {
		flags = mem_read_write | mem_copy_host_ptr
	}

	mut ret := 0

	memobj := cl_create_image(d.ctx, flags, format, desc, data, &ret)
	if ret != success {
		return vcl_error(ret)
	}

	if isnil(memobj) {
		return err_unknown
	}

	mut size := int(bounds.width * bounds.height)
	if image_type == ImageChannelOrder.rgba {
		size *= 4
	}

	buf := &Buffer{
		memobj: memobj
		size: size
		device: d
	}

	mut export_data := voidptr(unsafe { nill })
	if !isnil(data) {
		export_data = data.clone()
	}else {
		export_data = voidptr([]u8{len: size, cap: size, init: 0})
	}

	return &Image{
		buf: buf
		bounds: bounds
		@type: image_type
		format: format
		_data: export_data
		desc: desc
	}
}

pub fn (image &Image) data() ?&Image {
	origin := [usize(0), 0, 0]
	region := [usize(image.bounds.width), usize(image.bounds.height), 1]
	mut result := []u8{len: image.buf.size}
	ret := clEnqueueReadImage(image.buf.device.queue, img.buf.memobj, true, unsafe { &origin[0] },
		unsafe { &region[0] }, 0, 0, unsafe { &result[0] }, 0, unsafe { nil }, unsafe { nil })
	if ret != success {
		return vclError(ret)
	}
	return &Image{
		buf: image.buf
		bounds: image.bounds
		@type: image.@type
		format: image.format
		_data:  unsafe { voidptr(result) }
		desc: image.desc
	}
}



fn (image &Image) write_queue() ?int {
	origin := [usize(0), 0, 0]
	region := [usize(image.bounds.width), usize(image.bounds.height), 1]
	ret := clEnqueueWriteImage(image.buf.device.queue, img.buf.memobj, true, unsafe { &origin[0] },
		unsafe { &region[0] }, 0, 0, image._data, 0, unsafe { nil }, unsafe { nil })
	if ret != sussc {
		return vclError(ret)
	}
	return ret
}
