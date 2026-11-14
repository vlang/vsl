module vcl

fn C.create_image_desc(image_type ClMemObjectType, image_width uint, image_height uint, image_depth uint, image_array_size uint, image_row_pitch uint, image_slice_pitch uint, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc

@[inline]
fn create_image_desc(image_type ClMemObjectType, image_width uint, image_height uint, image_depth uint, image_array_size uint, image_row_pitch uint, image_slice_pitch uint, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc {
	return C.create_image_desc(image_type, image_width, image_height, image_depth,
		image_array_size, image_row_pitch, image_slice_pitch, num_mip_levels, num_samples, buffer)
}

fn C.create_image_format(image_channel_order uint, image_channel_data_type uint) &ClImageFormat

@[inline]
fn create_image_format(image_channel_order uint, image_channel_data_type uint) &ClImageFormat {
	return C.create_image_format(image_channel_order, image_channel_data_type)
}
