#ifndef VCL_OPENCL_H
#define VCL_OPENCL_H

#ifdef DARWIN
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#ifdef CL_VERSION_2_0
#define CL_VERSION_2_0_EXISTS true
#else
#define CL_VERSION_2_0_EXISTS false
#endif

cl_image_desc *create_image_desc(
    cl_mem_object_type image_type,
    size_t image_width,
    size_t image_height,
    size_t image_depth,
    size_t image_array_size,
    size_t image_row_pitch,
    size_t image_slice_pitch,
    cl_uint num_mip_levels,
    cl_uint num_samples,
    cl_mem buffer)
{
    cl_image_desc *desc = (cl_image_desc *)malloc(sizeof(cl_image_desc));
    desc->image_type = image_type;
    desc->image_width = image_width;
    desc->image_height = image_height;
    desc->image_row_pitch = image_row_pitch;
    desc->image_slice_pitch = image_slice_pitch;
    desc->num_mip_levels = num_mip_levels;
    desc->num_samples = num_samples;
    desc->buffer = buffer;
    return desc;
}

cl_image_format *create_image_format(
    cl_channel_order image_channel_order,
    cl_channel_type image_channel_data_type
) {
    cl_image_format *format = (cl_image_format *)malloc(sizeof(cl_image_format));
    format->image_channel_order = image_channel_order;
    format->image_channel_data_type = image_channel_data_type;
    return format;
}

#endif
