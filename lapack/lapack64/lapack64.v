module lapack64

/// dlamch_e is the machine epsilon. For IEEE this is 2^{-53}.
const dlamch_e = 1.1102230246251565e-16 // 2^-53

// dlamch_b is the radix of the machine (the base of the number system).
const dlamch_b = 2.0

// dlamch_p is base * eps.
const dlamch_p = dlamch_b * dlamch_e

// dlamch_s is the "safe minimum", that is, the lowest number such that
// 1/dlamch_s does not overflow, or also the smallest normal number.
// For IEEE this is 2^{-1022}.
const dlamch_s = 2.2250738585072014e-308 // 2^-1022

// Blue's scaling constants
//
// An n-vector x is well-scaled if
//  dtsml ≤ |xᵢ| ≤ dtbig for 0 ≤ i < n and n ≤ 1/dlamch_p,
// where
//  dtsml = 2^ceil((expmin-1)/2) = 2^ceil((-1021-1)/2) = 2^{-511} = 1.4916681462400413e-154
//  dtbig = 2^floor((expmax-digits+1)/2) = 2^floor((1024-53+1)/2) = 2^{486} = 1.997919072202235e+146
// If any xᵢ is not well-scaled, then multiplying small values by dssml and
// large values by dsbig avoids underflow or overflow when computing the sum
// of squares \sum_0^{n-1} (xᵢ)².
//  dssml = 2^{-floor((expmin-digits)/2)} = 2^{-floor((-1021-53)/2)} = 2^537 = 4.4989137945431964e+161
//  dsbig = 2^{-ceil((expmax+digits-1)/2)} = 2^{-ceil((1024+53-1)/2)} = 2^{-538} = 1.1113793747425387e-162
//
// References:
//  - Anderson E. (2017)
//    Algorithm 978: Safe Scaling in the Level 1 BLAS
//    ACM Trans Math Softw 44:1--28
//    https://doi.org/10.1145/3061665
//  - Blue, James L. (1978)
//    A Portable Fortran Program to Find the Euclidean Norm of a Vector
//    ACM Trans Math Softw 4:15--23
//    https://doi.org/10.1145/355769.355771

// dtsml constant
const dtsml = 1.4916681462400413e-154 // 2^-511

// dtbig constant
const dtbig = 1.997919072202235e+146 // 2^486

// dssml constant
const dssml = 4.4989137945431964e+161 // 2^537

// dsbig constant
const dsbig = 1.1113793747425387e-162 // 2^-538
