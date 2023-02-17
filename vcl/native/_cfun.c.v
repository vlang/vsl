module native

fn C.create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc
[inline]
pub fn create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc {
	return C.create_image_desc(image_type, image_width, image_height, image_depth, image_array_size,
		image_row_pitch, image_slice_pitch, num_mip_levels, num_samples, buffer)
}

fn C.create_image_format(image_channel_order usize, image_channel_data_type usize) &ClImageFormat
[inline]
pub fn create_image_format(image_channel_order usize, image_channel_data_type usize) &ClImageFormat {
	return C.create_image_format(image_channel_order, image_channel_data_type)
}
