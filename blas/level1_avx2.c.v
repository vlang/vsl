module blas

#flag @VMODROOT/level1_avx2.c

fn C.vsl_blas_avx2_supported() int
fn C.vsl_blas_avx2_fma_supported() int
fn C.vsl_blas_sdot_dispatch(n int, x &f32, y &f32) f32
fn C.vsl_blas_ddot_dispatch(n int, x &f64, y &f64) f64
fn C.vsl_blas_i16_dot_dispatch(n int, x &i16, y &i16) i64
fn C.vsl_blas_daxpy_dispatch(n int, alpha f64, x &f64, y &f64)
fn C.vsl_blas_dscal_dispatch(n int, alpha f64, x &f64)
fn C.vsl_blas_sgemv_n_dispatch(m int, n int, lda int, alpha f32, a &f32, x &f32, beta f32, y &f32)
fn C.vsl_blas_dgemv_n_dispatch(m int, n int, lda int, alpha f64, a &f64, x &f64, beta f64, y &f64)
fn C.vsl_blas_sgemv_t_dispatch(m int, n int, lda int, alpha f32, a &f32, x &f32, beta f32, y &f32)
fn C.vsl_blas_dgemv_t_dispatch(m int, n int, lda int, alpha f64, a &f64, x &f64, beta f64, y &f64)
