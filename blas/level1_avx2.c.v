module blas

#flag @VMODROOT/level1_avx2.c

fn C.vsl_blas_sdot_avx2_supported() int
fn C.vsl_blas_ddot_avx2_fma_supported() int
fn C.vsl_blas_sdot_dispatch(n int, x &f32, y &f32) f32
fn C.vsl_blas_ddot_dispatch(n int, x &f64, y &f64) f64
