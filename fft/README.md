# Fast Fourier Transform

The `fft` package is a wrapper of the C language version
of [PocketFFT](https://github.com/mreineck/pocketfft) library designed
to support FFT of real to complex and complex to real (arrays).

The result of a real-to-complex transform, because of mathematical symmetry of the
result, is stored in the original input array rather than 2x the space.

The output is the two real values bracketing the complex pairs
of conjugate negative frequencies: _r0 r1 i1 r2 i2 r3 i3 ... rx_

where _r0 + i0_ is the first complex result, _r1 - i1_ is the second, and so on
until _rx + i0_ (where _x_ is _n/2_) is the last. (Note the minus signs.)

The positive frequencies are the same as the negative frequencies in reverse
order. See the reference
for [FFTW](https://www.fftw.org/fftw3.pdf) for further examples of embeddings.

## Interleaved complex transforms

The complex FFT API supports both `f32` and `f64` interleaved buffers in the
form `[real0, imag0, real1, imag1, ...]`. Create a plan with
`create_complex_plan_f32(length)` or `create_complex_plan_f64(length)`, then
call the matching `forward_complex_f32`/`backward_complex_f32` or
`forward_complex_f64`/`backward_complex_f64` functions. They transform in
place, return `0` on success, and return `-1` when the plan or buffer length
does not match. The inverse is unnormalized; divide each component by the
original transform length for the normalized result. Destroy each plan
exactly once with `destroy_plan`.

The helpers require exactly twice the plan length in values of the matching
precision and validate that size before calling the native backend.

```v
import vsl.fft

mut samples := [f64(1), 0, 0, 0] // two complex values
plan := fft.create_complex_plan_f64(2)!
defer {
	fft.destroy_plan(plan)
}
fft.forward_complex_f64(plan, mut samples)
// Divide inverse results by 2 to normalize them.
fft.backward_complex_f64(plan, mut samples)
```

The single-precision API has the same plan and buffer contract:

```v
import vsl.fft

mut samples := [f32(1), 0, 0, 0]
plan := fft.create_complex_plan_f32(2)!
defer {
	fft.destroy_plan(plan)
}
fft.forward_complex_f32(plan, mut samples)
fft.backward_complex_f32(plan, mut samples)
```
