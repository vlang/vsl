# Fast Fourier Transform

The `fft` package is a wrapper of the C language version
of [PocketFFT](https://github.com/mreineck/pocketfft) library designed
to support FFT of real to complex and complex to real (arrays).

The result of a real-to-complex transform, because of mathematical symmetry of the
result, is stored in the original input array rather than 2x the space.

The output is the two real values bracketing the complex pairs
of conjugate negative frequencies:

_r0 r1 i1 r2 i2 r3 i3 ... rx_

where r0 + *i*0 is the first complex result, r1 - *i*i1 is the second, and so on
until rx + *i*0 (where x is n/2) is the last. (Note the minus signs.)

The positive frequencies are the same as the negative frequencies in reverse
order.  See the reference
for [FFTW](https://www.fftw.org/fftw3.pdf) for further examples of embeddings.


