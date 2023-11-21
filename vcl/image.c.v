module vcl

// Rect is a struct that represents a rectangle shape
@[params]
pub struct Rect {
pub: // pixel need integers
	x      f32
	y      f32
	width  f32
	height f32
}

// IImage holds the fileds and data needed to represent a bitmap/pixel based image in memory.
pub interface IImage {
	width       int
	height      int
	nr_channels int
	data        voidptr
}

// Image memory buffer on the device with image data
pub struct Image {
	format   ClImageFormat
	desc     &ClImageDesc = unsafe { nil }
	img_data voidptr
mut:
	buf &Buffer
pub:
	@type  ImageChannelOrder
	bounds Rect
}

// release releases the buffer on the device
pub fn (mut img Image) release() ! {
	return img.buf.release()
}

// image_2d allocates an image buffer
pub fn (d &Device) image_2d(@type ImageChannelOrder, bounds Rect) !&Image {
	return d.create_image_2d(@type, bounds, unsafe { nil })
}

// from_image_2d creates new Image and copies data from Image
pub fn (d &Device) from_image_2d(img IImage) !&Image {
	data := img.data
	mut image_type := ImageChannelOrder.intensity

	if img.nr_channels in [3, 4] {
		image_type = ImageChannelOrder.rgba
	}

	bounds := Rect{0, 0, img.width, img.height}
	return d.create_image_2d(image_type, bounds, data)
}

// create_image_2d creates a new image
fn (d &Device) create_image_2d(image_type ImageChannelOrder, bounds Rect, data voidptr) !&Image {
	mut row_pitch := int(bounds.width)
	mut size := int(bounds.width * bounds.height)
	if image_type == ImageChannelOrder.rgba {
		size *= 4
		row_pitch *= 4
	}
	format := C.create_image_format(usize(image_type), usize(ImageChannelDataType.unorm_int8))

	mut flags := mem_read_write

	if !isnil(data) {
		flags = mem_read_write | mem_copy_host_ptr
	}
	mut ret := 0
	memobj := cl_create_image2d(d.ctx, flags, format, usize(bounds.width), usize(bounds.height),
		usize(row_pitch), data, &ret)
	if ret != success {
		return error_from_code(ret)
	}

	if isnil(memobj) {
		return err_unknown
	}

	buf := &Buffer{
		memobj: memobj
		size: size
		device: d
	}

	img := &Image{
		buf: buf
		bounds: bounds
		@type: image_type
		format: format
		img_data: data
		desc: unsafe { nil }
	}
	if !isnil(data) {
		img.write_queue()!
	}
	return img
}

pub fn (image &Image) data_2d() ![]u8 {
	origin := [3]usize{init: 0}
	region0 := [usize(image.bounds.width), usize(image.bounds.height), 1]
	region := [3]usize{init: region0[index]}
	result := []u8{len: image.buf.size, cap: image.buf.size}
	ret := cl_enqueue_read_image(image.buf.device.queue, image.buf.memobj, true, origin,
		region, 0, 0, unsafe { &result[0] }, 0, unsafe { nil }, unsafe { nil })
	return error_or_default(ret, result)
}

fn (image &Image) write_queue() !int {
	mut origin := [3]usize{}
	mut region := [3]usize{}
	temp := [usize(image.bounds.width), usize(image.bounds.height), 1]
	for i := 0; i < 3; i++ {
		origin[i] = 0
		region[i] = temp[i]
	}

	ret := cl_enqueue_write_image(image.buf.device.queue, image.buf.memobj, true, origin,
		region, 0, 0, image.img_data, 0, unsafe { nil }, unsafe { nil })
	return error_or_default(ret, ret)
}

// image_general allocates an image buffer TODO not accomplish - broken
fn (d &Device) image_general(@type ImageChannelOrder, bounds Rect) !&Image {
	println(@STRUCT + '.' + @FN + ' is not stable yet. Issues are expected.')
	return d.create_image_general(@type, bounds, 0, unsafe { nil })
}

// from_image_general creates new Image and copies data from Image TODO not accomplish - broken
fn (d &Device) from_image_general(img IImage) !&Image {
	println(@STRUCT + '.' + @FN + ' is not stable yet. Issues are expected.')
	data := img.data
	mut row_pitch := 0
	mut image_type := ImageChannelOrder.intensity

	if img.nr_channels in [3, 4] {
		image_type = ImageChannelOrder.rgba
	}

	bounds := Rect{0, 0, img.width, img.height}
	return d.create_image_general(image_type, bounds, row_pitch, data)
}

// create_image_general creates a new image TODO not accomplish - broken
fn (d &Device) create_image_general(image_type ImageChannelOrder, bounds Rect, row_pitch int, data voidptr) !&Image {
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
		return error_from_code(ret)
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

	return &Image{
		buf: buf
		bounds: bounds
		@type: image_type
		format: format
		desc: desc
	}
}

// buffer returns the underlying buffer
fn (image &Image) buffer() &Buffer {
	return image.buf
}
