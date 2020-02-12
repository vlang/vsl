// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module blas

#include "openblas_cblas.h"
fn C.cblas_ddot(n int, dx &f64, incx int, dy &f64, incy int) f64


fn C.cblas_dger(m int, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)


fn C.cblas_dnrm2(n int, x &f64, incx int) f64


fn C.cblas_idamax(n int, x &f64, incx int) int


fn C.cblas_daxpy(n int, alpha f64, x &f64, incx int, y &f64, incy int)


fn C.cblas_dgemv(trans byte, m int, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)


fn C.cblas_dgemm(trans byte, m int, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, c &f64, ldc int)
