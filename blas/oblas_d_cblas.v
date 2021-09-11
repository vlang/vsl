module blas

import vsl.blas.vlas

// #include <cblas.h>

fn C.openblas_set_num_threads(n int)

fn C.cblas_sdsdot(n int, alpha f32, x &f32, incx int, y &f32, incy int) f32
fn C.cblas_dsdot(n int, x &f32, incx int, y &f32, incy int) f64
fn C.cblas_sdot(n int, x &f32, incx int, y &f32, incy int) f32
fn C.cblas_ddot(n int, x &f64, incx int, y &f64, incy int) f64
fn C.cblas_cdotu(n int, x voidptr, incx int, y voidptr, incy int) f32
fn C.cblas_cdotc(n int, x voidptr, incx int, y voidptr, incy int) f32
fn C.cblas_zdotu(n int, x voidptr, incx int, y voidptr, incy int) f64
fn C.cblas_zdotc(n int, x voidptr, incx int, y voidptr, incy int) f64
fn C.cblas_cdotu_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_cdotc_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_zdotu_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_zdotc_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_sasum(n int, x &f32, incx int) f32
fn C.cblas_dasum(n int, x &f64, incx int) f64
fn C.cblas_scasum(n int, x voidptr, incx int) f32
fn C.cblas_dzasum(n int, x voidptr, incx int) f64
fn C.cblas_ssum(n int, x &f32, incx int) f32
fn C.cblas_dsum(n int, x &f64, incx int) f64
fn C.cblas_scsum(n int, x voidptr, incx int) f32
fn C.cblas_dzsum(n int, x voidptr, incx int) f64
fn C.cblas_snrm2(n int, x &f32, incx int) f32
fn C.cblas_dnrm2(n int, x &f64, incx int) f64
fn C.cblas_scnrm2(n int, x voidptr, incx int) f32
fn C.cblas_dznrm2(n int, x voidptr, incx int) f64

fn C.cblas_isamax(n int, x &f32, incx int) int
fn C.cblas_idamax(n int, x &f64, incx int) int
fn C.cblas_icamax(n int, x voidptr, incx int) int
fn C.cblas_izamax(n int, x voidptr, incx int) int
fn C.cblas_isamin(n int, x &f32, incx int) int
fn C.cblas_idamin(n int, x &f64, incx int) int
fn C.cblas_icamin(n int, x voidptr, incx int) int
fn C.cblas_izamin(n int, x voidptr, incx int) int
fn C.cblas_ismax(n int, x &f32, incx int) int
fn C.cblas_idmax(n int, x &f64, incx int) int
fn C.cblas_icmax(n int, x voidptr, incx int) int
fn C.cblas_izmax(n int, x voidptr, incx int) int
fn C.cblas_ismin(n int, x &f32, incx int) int
fn C.cblas_idmin(n int, x &f64, incx int) int
fn C.cblas_icmin(n int, x voidptr, incx int) int
fn C.cblas_izmin(n int, x voidptr, incx int) int
fn C.cblas_saxpy(n int, alpha f32, x &f32, incx int, y &f32, incy int)
fn C.cblas_daxpy(n int, alpha f64, x &f64, incx int, y &f64, incy int)
fn C.cblas_caxpy(n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_zaxpy(n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_scopy(n int, x &f32, incx int, y &f32, incy int)
fn C.cblas_dcopy(n int, x &f64, incx int, y &f64, incy int)
fn C.cblas_ccopy(n int, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_zcopy(n int, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_sswap(n int, x &f32, incx int, y &f32, incy int)
fn C.cblas_dswap(n int, x &f64, incx int, y &f64, incy int)
fn C.cblas_cswap(n int, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_zswap(n int, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_srot(n int, x &f32, incx int, y &f32, incy int, c f32, s f32)
fn C.cblas_drot(n int, x &f64, incx int, y &f64, incy int, c f64, s f64)
fn C.cblas_srotg(a &f32, b &f32, c &f32, s &f32)
fn C.cblas_drotg(a &f64, b &f64, c &f64, s &f64)
fn C.cblas_srotm(n int, x &f32, incx int, y &f32, incy int, p &f32)
fn C.cblas_drotm(n int, x &f64, incx int, y &f64, incy int, p &f64)
fn C.cblas_srotmg(d1 &f32, d2 &f32, b1 &f32, b2 f32, p &f32)
fn C.cblas_drotmg(d1 &f64, d2 &f64, b1 &f64, b2 f64, p &f64)
fn C.cblas_sscal(n int, alpha f32, x &f32, incx int)
fn C.cblas_dscal(n int, alpha f64, x &f64, incx int)
fn C.cblas_cscal(n int, alpha voidptr, x voidptr, incx int)
fn C.cblas_zscal(n int, alpha voidptr, x voidptr, incx int)
fn C.cblas_csscal(n int, alpha f32, x voidptr, incx int)
fn C.cblas_zdscal(n int, alpha f64, x voidptr, incx int)
fn C.cblas_sgemv(order vlas.MemoryLayout, trans vlas.Transpose, m int, n int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgemv(order vlas.MemoryLayout, trans vlas.Transpose, m int, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgemv(order vlas.MemoryLayout, trans vlas.Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgemv(order vlas.MemoryLayout, trans vlas.Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sger(order vlas.MemoryLayout, m int, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32, lda int)
fn C.cblas_dger(order vlas.MemoryLayout, m int, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)
fn C.cblas_cgeru(order vlas.MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_cgerc(order vlas.MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgeru(order vlas.MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgerc(order vlas.MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_strsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_strmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ssyr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x &f32, incx int, a &f32, lda int)
fn C.cblas_dsyr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x &f64, incx int, a &f64, lda int)
fn C.cblas_cher(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_zher(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_ssyr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32, lda int)
fn C.cblas_dsyr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)
fn C.cblas_cher2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zher2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_sgbmv(order vlas.MemoryLayout, transA vlas.Transpose, m int, n int, kl int, ku int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgbmv(order vlas.MemoryLayout, transA vlas.Transpose, m int, n int, kl int, ku int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgbmv(order vlas.MemoryLayout, transA vlas.Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgbmv(order vlas.MemoryLayout, transA vlas.Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_ssbmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, k int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsbmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, k int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_stbmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stbsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stpmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap &f32, x &f32, incx int)
fn C.cblas_dtpmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap &f64, x &f64, incx int)
fn C.cblas_ctpmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpmv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_stpsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap &f32, x &f32, incx int)
fn C.cblas_dtpsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap &f64, x &f64, incx int)
fn C.cblas_ctpsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpsv(order vlas.MemoryLayout, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ssymv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsymv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_chemv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhemv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sspmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, ap &f32, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dspmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, ap &f64, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_sspr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x &f32, incx int, ap &f32)
fn C.cblas_dspr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x &f64, incx int, ap &f64)
fn C.cblas_chpr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x voidptr, incx int, a voidptr)
fn C.cblas_zhpr(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x voidptr, incx int, a voidptr)
fn C.cblas_sspr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32)
fn C.cblas_dspr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64)
fn C.cblas_chpr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_zhpr2(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_chbmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhbmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_chpmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhpmv(order vlas.MemoryLayout, uplo vlas.Uplo, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sgemm(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dgemm(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_cgemm(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cgemm3m(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm3m(order vlas.MemoryLayout, transA vlas.Transpose, transB vlas.Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssymm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsymm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csymm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsymm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyrk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f32, a &f32, lda int, beta f32, c &f32, ldc int)
fn C.cblas_dsyrk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f64, a &f64, lda int, beta f64, c &f64, ldc int)
fn C.cblas_csyrk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyrk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyr2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsyr2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csyr2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyr2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_strmm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrmm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrmm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrmm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_strsm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrsm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrsm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrsm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, transA vlas.Transpose, diag vlas.Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_chemm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zhemm(order vlas.MemoryLayout, side vlas.Side, uplo vlas.Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cherk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f32, a voidptr, lda int, beta f32, c voidptr, ldc int)
fn C.cblas_zherk(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha f64, a voidptr, lda int, beta f64, c voidptr, ldc int)
fn C.cblas_cher2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f32, c voidptr, ldc int)
fn C.cblas_zher2k(order vlas.MemoryLayout, uplo vlas.Uplo, trans vlas.Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f64, c voidptr, ldc int)
fn C.cblas_xerbla(p int, rout &byte, form &byte, other voidptr)

fn C.cblas_saxpby(n int, alpha f32, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_daxpby(n int, alpha f64, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_caxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zaxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_somatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha f32, a &f32, clda int, b &f32, cldb int)
fn C.cblas_domatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha f64, a &f64, clda int, b &f64, cldb int)
fn C.cblas_comatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha &f32, a &f32, clda int, b &f32, cldb int)
fn C.cblas_zomatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha &f64, a &f64, clda int, b &f64, cldb int)
fn C.cblas_simatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha f32, a &f32, clda int, cldb int)
fn C.cblas_dimatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha f64, a &f64, clda int, cldb int)
fn C.cblas_cimatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha &f32, a &f32, clda int, cldb int)
fn C.cblas_zimatcopy(corder vlas.MemoryLayout, ctrans vlas.Transpose, crows int, ccols int, calpha &f64, a &f64, clda int, cldb int)
fn C.cblas_sgeadd(corder vlas.MemoryLayout, crows int, ccols int, calpha f32, a &f32, clda int, cbeta f32, c &f32, cldc int)
fn C.cblas_dgeadd(corder vlas.MemoryLayout, crows int, ccols int, calpha f64, a &f64, clda int, cbeta f64, c &f64, cldc int)
fn C.cblas_cgeadd(corder vlas.MemoryLayout, crows int, ccols int, calpha &f32, a &f32, clda int, cbeta &f32, c &f32, cldc int)
fn C.cblas_zgeadd(corder vlas.MemoryLayout, crows int, ccols int, calpha &f64, a &f64, clda int, cbeta &f64, c &f64, cldc int)

// set_num_threads sets the number of threads in OpenBLAS
pub fn set_num_threads(n int) {
	C.openblas_set_num_threads(n)
}

[inline]
pub fn sdsdot(n int, alpha f32, x []f32, incx int, y []f32, incy int) f32 {
	return C.cblas_sdsdot(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn dsdot(n int, x []f32, incx int, y []f32, incy int) f64 {
	return C.cblas_dsdot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn sdot(n int, x []f32, incx int, y []f32, incy int) f32 {
	return C.cblas_sdot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return C.cblas_ddot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn sasum(n int, x []f32, incx int) f32 {
	return C.cblas_sasum(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return C.cblas_dasum(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn ssum(n int, x []f32, incx int) f32 {
	return C.cblas_ssum(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn dsum(n int, x []f64, incx int) f64 {
	return C.cblas_dsum(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn snrm2(n int, x []f32, incx int) f32 {
	return C.cblas_snrm2(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return C.cblas_dnrm2(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn isamax(n int, x []f32, incx int) int {
	return C.cblas_isamax(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn idamax(n int, x []f64, incx int) int {
	return C.cblas_idamax(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn isamin(n int, x []f32, incx int) int {
	return C.cblas_isamin(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn idamin(n int, x &f64, incx int) int {
	return C.cblas_idamin(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn ismax(n int, x []f32, incx int) int {
	return C.cblas_ismax(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn idmax(n int, x []f64, incx int) int {
	return C.cblas_idmax(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn ismin(n int, x []f32, incx int) int {
	return C.cblas_ismin(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn idmin(n int, x []f64, incx int) int {
	return C.cblas_idmin(n, unsafe { &x[0] }, incx)
}

[inline]
pub fn saxpy(n int, alpha f32, x []f32, incx int, mut y []f32, incy int) {
	C.cblas_saxpy(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	C.cblas_daxpy(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn scopy(n int, x []f32, incx int, mut y []f32, incy int) {
	C.cblas_scopy(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	C.cblas_dcopy(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn sswap(n int, x []f32, incx int, mut y []f32, incy int) {
	C.cblas_sswap(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn dswap(n int, x []f64, incx int, mut y []f64, incy int) {
	C.cblas_dswap(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

[inline]
pub fn srot(n int, x []f32, incx int, mut y []f32, incy int, c f32, s f32) {
	C.cblas_srot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, c, s)
}

[inline]
pub fn drot(n int, x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	C.cblas_drot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, c, s)
}

[inline]
pub fn srotg(a f32, b f32, c f32, s f32) {
	C.cblas_srotg(&a, &b, &c, &s)
}

[inline]
pub fn drotg(a f64, b f64, c f64, s f64) {
	C.cblas_drotg(&a, &b, &c, &s)
}

[inline]
pub fn srotm(n int, x []f32, incx int, y []f32, incy int, p []f32) {
	C.cblas_srotm(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, unsafe { &p[0] })
}

[inline]
pub fn drotm(n int, x []f64, incx int, y []f64, incy int, p []f64) {
	C.cblas_drotm(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, unsafe { &p[0] })
}

[inline]
pub fn srotmg(d1 f32, d2 f32, b1 f32, b2 f32, p []f32) {
	C.cblas_srotmg(&d1, &d2, &b1, b2, unsafe { &p[0] })
}

[inline]
pub fn drotmg(d1 f64, d2 f64, b1 f64, b2 f32, p []f64) {
	C.cblas_drotmg(&d1, &d2, &b1, b2, unsafe { &p[0] })
}

[inline]
pub fn sscal(n int, alpha f32, x []f32, incx int) {
	C.cblas_sscal(n, alpha, unsafe { &x[0] }, incx)
}

[inline]
pub fn dscal(n int, alpha f64, x []f64, incx int) {
	C.cblas_dscal(n, alpha, unsafe { &x[0] }, incx)
}

[inline]
pub fn sgemv(trans bool, m int, n int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sgemv(.row_major, c_trans(trans), m, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

[inline]
pub fn dgemv(trans bool, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dgemv(.row_major, c_trans(trans), m, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

[inline]
pub fn sger(m int, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32, lda int) {
	C.cblas_sger(.row_major, m, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy,
		unsafe { &a[0] }, lda)
}

[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	C.cblas_dger(.row_major, m, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy,
		unsafe { &a[0] }, lda)
}

[inline]
pub fn strsv(uplo bool, trans_a bool, diag vlas.Diagonal, n int, a []f32, lda int, x []f32, incx int) {
	C.cblas_strsv(.row_major, c_uplo(uplo), c_trans(trans_a), diag, n, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx)
}

[inline]
pub fn dtrsv(uplo bool, trans_a bool, diag vlas.Diagonal, n int, a []f64, lda int, x []f64, incx int) {
	C.cblas_dtrsv(.row_major, c_uplo(uplo), c_trans(trans_a), diag, n, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx)
}

[inline]
pub fn strmv(uplo bool, trans_a bool, diag vlas.Diagonal, n int, a []f32, lda int, x []f32, incx int) {
	C.cblas_strmv(.row_major, c_uplo(uplo), c_trans(trans_a), diag, n, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx)
}

[inline]
pub fn dtrmv(uplo bool, trans_a bool, diag vlas.Diagonal, n int, a []f64, lda int, x []f64, incx int) {
	C.cblas_dtrmv(.row_major, c_uplo(uplo), c_trans(trans_a), diag, n, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx)
}

[inline]
pub fn ssyr(uplo bool, n int, alpha f32, x []f32, incx int, a []f32, lda int) {
	C.cblas_ssyr(.row_major, c_uplo(uplo), n, alpha, unsafe { &x[0] }, incx, unsafe { &a[0] },
		lda)
}

[inline]
pub fn dsyr(uplo bool, n int, alpha f64, x []f64, incx int, a []f64, lda int) {
	C.cblas_dsyr(.row_major, c_uplo(uplo), n, alpha, unsafe { &x[0] }, incx, unsafe { &a[0] },
		lda)
}

[inline]
pub fn ssyr2(uplo bool, n int, alpha f32, x []f32, incx int, y []f32, incy int, a []f32, lda int) {
	C.cblas_ssyr2(.row_major, c_uplo(uplo), n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] }, lda)
}

[inline]
pub fn dsyr2(uplo bool, n int, alpha f64, x []f64, incx int, y []f64, incy int, a []f64, lda int) {
	C.cblas_dsyr2(.row_major, c_uplo(uplo), n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] }, lda)
}

[inline]
pub fn sgemm(trans_a bool, trans_b bool, m int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut cc []f32, ldc int) {
	C.cblas_sgemm(.row_major, c_trans(trans_a), c_trans(trans_b), m, n, k, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb, beta, unsafe { &cc[0] }, ldc)
}

[inline]
pub fn dgemm(trans_a bool, trans_b bool, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	C.cblas_dgemm(.row_major, c_trans(trans_a), c_trans(trans_b), m, n, k, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb, beta, unsafe { &cc[0] }, ldc)
}
