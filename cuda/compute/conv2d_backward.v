// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// conv2d_backward_cuda — cuDNN backward data + backward filter (same padding as conv2d_cuda).
import vsl.cuda

// Conv2DBwdFlat holds flat NCHW gradients for input and filter.
pub struct Conv2DBwdFlat {
pub:
	d_input  []f64
	d_weight []f64
}

pub fn conv2d_backward_cuda(dev &cuda.CudaDevice, grad_out []f64, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) !Conv2DBwdFlat {
	if isnil(dev.cudnn) {
		return error('conv2d_backward_cuda: cuDNN handle not available')
	}

	mut in_tensor_desc := cuda.CudnnTensorDescriptor(unsafe { nil })
	s0 := C.cudnnCreateTensorDescriptor(&in_tensor_desc)
	if s0 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnCreateTensorDescriptor(in): ${cuda.cudnn_error(s0)}')
	}
	s0b := C.cudnnSetTensor4dDescriptor(in_tensor_desc, cuda.cudnn_tensor_nchw,
		cuda.cudnn_data_type_double, batch, in_ch, in_h, in_w)
	if s0b != cuda.cudnn_status_success {
		C.cudnnDestroyTensorDescriptor(in_tensor_desc)
		return error('conv2d_backward_cuda: cudnnSetTensor4dDescriptor(in): ${cuda.cudnn_error(s0b)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(in_tensor_desc) }

	mut filter_desc := cuda.CudnnFilterDescriptor(unsafe { nil })
	s1 := C.cudnnCreateFilterDescriptor(&filter_desc)
	if s1 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnCreateFilterDescriptor: ${cuda.cudnn_error(s1)}')
	}
	s1b := C.cudnnSetFilter4dDescriptor(filter_desc, cuda.cudnn_data_type_double,
		cuda.cudnn_tensor_nchw, out_ch, in_ch, k_h, k_w)
	if s1b != cuda.cudnn_status_success {
		C.cudnnDestroyFilterDescriptor(filter_desc)
		return error('conv2d_backward_cuda: cudnnSetFilter4dDescriptor: ${cuda.cudnn_error(s1b)}')
	}
	defer { C.cudnnDestroyFilterDescriptor(filter_desc) }

	mut conv_desc := cuda.CudnnConvolutionDescriptor(unsafe { nil })
	s2 := C.cudnnCreateConvolutionDescriptor(&conv_desc)
	if s2 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnCreateConvolutionDescriptor: ${cuda.cudnn_error(s2)}')
	}
	pad_h := (k_h - 1) / 2
	pad_w := (k_w - 1) / 2
	s2b := C.cudnnSetConvolution2dDescriptor(conv_desc, pad_h, pad_w, stride_h, stride_w, 1, 1, 0)
	if s2b != cuda.cudnn_status_success {
		C.cudnnDestroyConvolutionDescriptor(conv_desc)
		return error('conv2d_backward_cuda: cudnnSetConvolution2dDescriptor: ${cuda.cudnn_error(s2b)}')
	}
	defer { C.cudnnDestroyConvolutionDescriptor(conv_desc) }

	mut out_n := 0
	mut out_c := 0
	mut out_h_res := 0
	mut out_w_res := 0
	s3 := C.cudnnGetConvolution2dForwardOutputDim(conv_desc, in_tensor_desc, filter_desc, &out_n,
		&out_c, &out_h_res, &out_w_res)
	if s3 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnGetConvolution2dForwardOutputDim: ${cuda.cudnn_error(s3)}')
	}

	mut dy_tensor_desc := cuda.CudnnTensorDescriptor(unsafe { nil })
	s4 := C.cudnnCreateTensorDescriptor(&dy_tensor_desc)
	if s4 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnCreateTensorDescriptor(dy): ${cuda.cudnn_error(s4)}')
	}
	s4b := C.cudnnSetTensor4dDescriptor(dy_tensor_desc, cuda.cudnn_tensor_nchw,
		cuda.cudnn_data_type_double, out_n, out_c, out_h_res, out_w_res)
	if s4b != cuda.cudnn_status_success {
		C.cudnnDestroyTensorDescriptor(dy_tensor_desc)
		return error('conv2d_backward_cuda: cudnnSetTensor4dDescriptor(dy): ${cuda.cudnn_error(s4b)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(dy_tensor_desc) }

	data_algo := cuda.CudnnConvolutionBwdDataAlgo(0)
	filter_algo := cuda.CudnnConvolutionBwdFilterAlgo(0)

	mut ws_data := usize(0)
	mut ws_filter := usize(0)
	sw0 := C.cudnnGetConvolutionBackwardDataWorkspaceSize(dev.cudnn, filter_desc, dy_tensor_desc,
		conv_desc, in_tensor_desc, data_algo, &ws_data)
	if sw0 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: BackwardDataWorkspaceSize: ${cuda.cudnn_error(sw0)}')
	}
	sw1 := C.cudnnGetConvolutionBackwardFilterWorkspaceSize(dev.cudnn, in_tensor_desc,
		dy_tensor_desc, conv_desc, filter_desc, filter_algo, &ws_filter)
	if sw1 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: BackwardFilterWorkspaceSize: ${cuda.cudnn_error(sw1)}')
	}
	ws_bytes := if ws_data > ws_filter { ws_data } else { ws_filter }

	in_size := batch * in_ch * in_h * in_w
	k_size := out_ch * in_ch * k_h * k_w
	dy_size := out_n * out_c * out_h_res * out_w_res

	mut d_x := gpu_buf_new[f64](in_size)!
	defer { d_x.release() }
	mut d_w := gpu_buf_new[f64](k_size)!
	defer { d_w.release() }
	mut d_dy := gpu_buf_new[f64](dy_size)!
	defer { d_dy.release() }
	mut d_dx := gpu_buf_new[f64](in_size)!
	defer { d_dx.release() }
	mut d_dw := gpu_buf_new[f64](k_size)!
	defer { d_dw.release() }

	mut d_ws := GpuBuf{}
	if ws_bytes > 0 {
		d_ws = gpu_buf_new[u8](int(ws_bytes))!
		defer { d_ws.release() }
	}

	d_x.upload[f64](input)!
	d_w.upload[f64](kernel)!
	d_dy.upload[f64](grad_out)!

	alpha := f64(1.0)
	beta := f64(0.0)
	s5 := C.cudnnConvolutionBackwardData(dev.cudnn, &alpha, filter_desc, &f64(d_w.ptr),
		dy_tensor_desc, &f64(d_dy.ptr), conv_desc, data_algo, d_ws.ptr, int(ws_bytes), &beta,
		in_tensor_desc, &f64(d_dx.ptr))
	if s5 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnConvolutionBackwardData: ${cuda.cudnn_error(s5)}')
	}
	s6 := C.cudnnConvolutionBackwardFilter(dev.cudnn, &alpha, in_tensor_desc, &f64(d_x.ptr),
		dy_tensor_desc, &f64(d_dy.ptr), conv_desc, filter_algo, d_ws.ptr, int(ws_bytes), &beta,
		filter_desc, &f64(d_dw.ptr))
	if s6 != cuda.cudnn_status_success {
		return error('conv2d_backward_cuda: cudnnConvolutionBackwardFilter: ${cuda.cudnn_error(s6)}')
	}

	mut d_input := []f64{len: in_size}
	mut d_weight := []f64{len: k_size}
	d_dx.download[f64](mut d_input)!
	d_dw.download[f64](mut d_weight)!
	return Conv2DBwdFlat{
		d_input:  d_input
		d_weight: d_weight
	}
}
