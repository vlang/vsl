module fft

#flag -I @VMODROOT/src
#flag @VMODROOT/src/f32.o
#flag @VMODROOT/src/f64.o
#include "pocketfft_f32.h"
#include "pocketfft_f64.h"

type FftSizeT = u64

struct C.cfft_plan_i_f32 {
	packplan C.cfftp_plan_f32
	blueplan C.cfftblue_plan_f32
}

struct C.cfft_plan_i_f64 {
	packplan C.cfftp_plan_f64
	blueplan C.cfftblue_plan_f64
}

struct C.rfft_plan_i_f32 {
	packplan C.rfftp_plan_f32
	blueplan C.rfftblue_plan_f32
}

struct C.rfft_plan_i_f64 {
	packplan C.cfftp_plan_f64
	blueplan C.cfftblue_plan_f64
}

// F32
fn C.cfft_forward_f32(plan C.cfft_plan_f32, c []f32, fct f32) int
fn C.cfft_backward_f32(plan C.cfft_plan_f32, c []f32, fct f32) int

fn C.make_cfft_plan_f32(length int) C.cfft_plan_f32
fn C.destroy_cfft_plan_f32(plan C.cfft_plan_f32)

fn C.rfft_forward_f32(plan C.rfft_plan_f32, c []f32, fct f32) int
fn C.rfft_backward_f32(plan C.rfft_plan_f32, c []f32, fct f32) int

fn C.make_rfft_plan_f32(length int) C.rfft_plan_f32
fn C.destroy_rfft_plan_f32(plan C.rfft_plan_f32)

// F64
fn C.cfft_forward_f64(plan C.cfft_plan_f64, c []f64, fct f64) int
fn C.cfft_backward_f64(plan C.cfft_plan_f64, c []f64, fct f64) int

fn C.make_cfft_plan_f64(length int) C.cfft_plan_f64
fn C.destroy_cfft_plan_f64(plan C.cfft_plan_f64)

fn C.rfft_forward_f64(plan C.rfft_plan_f64, c []f64, fct f64) int
fn C.rfft_backward_f64(plan C.rfft_plan_f64, c []f64, fct f64) int

fn C.make_rfft_plan_f64(length int) C.rfft_plan_f64
fn C.destroy_rfft_plan_f64(plan C.rfft_plan_f64)

struct Fft32 {
mut:
	plan C.rfft_plan_f32
}

struct Fft64 {
mut:
	plan C.rfft_plan_f64
}

struct Cfft32 {
mut:
	plan C.cfft_plan_f32
}

struct Cfft64 {
mut:
	plan C.cfft_plan_f64
}

type Fftplan = Cfft32 | Cfft64 | Fft32 | Fft64

struct Cmplx32 {
pub mut:
	re f32
	im f32
}

struct Cmplx64 {
pub mut:
	re f64
	im f64
}

// create_plan returns a plan to compute a Fourier transform of the given array
// A plan is reusable for any array of exactly this size and type.
// The array may be []f32, []f64, or []complx_f32 or []complex_f64.
pub fn create_plan[T](x T) ?Fftplan {
	$if T is []f32 {
		return Fftplan(Fft32{C.make_rfft_plan_f32(x.len)})
	} $else $if T is []f64 {
		return Fftplan(Fft64{C.make_rfft_plan_f64(x.len)})
	} $else $if T is []cmplx_f32 {
		return Fftplan(Cfft32{C.make_cfft_plan_f32(x.len)})
	} $else $if T is []cmplx_f64 {
		return Fftplan(Cfft64{C.make_cfft_plan_f64(x.len)})
	} $else {
		eprintln('fftplan unsupported type: ${typeof(x).name}')
	}
	return none
}

// forward_fft computes a Fourier transform defined by the plan p
// The input is []f32 or []f64.
// The output result (r) is returned in-place, and is complex
// and real numbers mixed as follows:
//    r[0] (im[0] is assumed and is 0)
//    r[1] im[1] ... r[n/2] im[n/2]   conjugate negative frequences
//    r[n] is the magnitude at zero frequency (im[n] is assumed and is 0)
// Positive frequencies are excluded as these are symmetric to the negative
// frequencies for real inputs.  (Consult any signal processing text for details.)
//
// To generate a complete result, copy the results to a larger complex array
// using
//   r[0] and i*0
//   r[1] and i*-r[2]
//   r[3] and i*-r[4]
//   ...
//   r[n] and i*0     at the zero frequency
//   r[n-2] and i*r[n-1]   the complex conjugate negative frequencies
//   r[n-4] and i*r[n-3]   in reverse order
//   ...
//   r[1] and i*r[2]
//
// Note: these codes allocate and free memory of the same size as the input.

pub fn forward_fft[T](p Fftplan, v T) int {
	match p {
		Fft32 {
			return C.rfft_forward_f32(p.plan, v.data, f32(1.0))
		}
		Fft64 {
			return C.rfft_forward_f64(p.plan, v.data, f64(1.0))
		}
		Cfft32 {
			return C.cfft_forward_f32(p.plan, v.data, f32(1.0))
		}
		Cfft64 {
			return C.cfft_forward_f64(p.plan, v.data, f64(1.0))
		}
	}
}

// backward_fft computes the backwards Fourier transform defined by the plan r
pub fn backward_fft[T](r Fftplan, v T) int {
	match r {
		Fft32 {
			return C.rfft_backward_f32(r.plan, v.data, f32(1.0))
		}
		Fft64 {
			return C.rfft_backward_f64(r.plan, v.data, f64(1.0))
		}
		Cfft32 {
			return C.cfft_backward_f32(r.plan, v.data, f32(1.0))
		}
		Cfft64 {
			return C.cfft_backward_f64(r.plan, v.data, f64(1.0))
		}
	}
}
