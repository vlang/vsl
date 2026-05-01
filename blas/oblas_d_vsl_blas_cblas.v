module blas

import vsl.blas.blas64

fn C.openblas_set_num_threads(n int)

fn C.cblas_sdsdot(n int, alpha f32, const_x &f32, incx int, const_y &f32, incy int) f32
fn C.cblas_dsdot(n int, const_x &f32, incx int, const_y &f32, incy int) f64
fn C.cblas_sdot(n int, const_x &f32, incx int, const_y &f32, incy int) f32
fn C.cblas_ddot(n int, const_x &f64, incx int, const_y &f64, incy int) f64
fn C.cblas_cdotu(n int, x voidptr, incx int, y voidptr, incy int) f32
fn C.cblas_cdotc(n int, x voidptr, incx int, y voidptr, incy int) f32
fn C.cblas_zdotu(n int, x voidptr, incx int, y voidptr, incy int) f64
fn C.cblas_zdotc(n int, x voidptr, incx int, y voidptr, incy int) f64
fn C.cblas_cdotu_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_cdotc_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_zdotu_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_zdotc_sub(n int, x voidptr, incx int, y voidptr, incy int, ret voidptr)
fn C.cblas_sasum(n int, const_x &f32, incx int) f32
fn C.cblas_dasum(n int, const_x &f64, incx int) f64
fn C.cblas_scasum(n int, x voidptr, incx int) f32
fn C.cblas_dzasum(n int, x voidptr, incx int) f64
fn C.cblas_ssum(n int, const_x &f32, incx int) f32
fn C.cblas_dsum(n int, const_x &f64, incx int) f64
fn C.cblas_scsum(n int, x voidptr, incx int) f32
fn C.cblas_dzsum(n int, x voidptr, incx int) f64
fn C.cblas_snrm2(n int, const_x &f32, incx int) f32
fn C.cblas_dnrm2(n int, const_x &f64, incx int) f64
fn C.cblas_scnrm2(n int, x voidptr, incx int) f32
fn C.cblas_dznrm2(n int, x voidptr, incx int) f64

fn C.cblas_isamax(n int, const_x &f32, incx int) int
fn C.cblas_idamax(n int, const_x &f64, incx int) int
fn C.cblas_icamax(n int, x voidptr, incx int) int
fn C.cblas_izamax(n int, x voidptr, incx int) int
fn C.cblas_isamin(n int, const_x &f32, incx int) int
fn C.cblas_idamin(n int, const_x &f64, incx int) int
fn C.cblas_icamin(n int, x voidptr, incx int) int
fn C.cblas_izamin(n int, x voidptr, incx int) int
fn C.cblas_ismax(n int, const_x &f32, incx int) int
fn C.cblas_idmax(n int, const_x &f64, incx int) int
fn C.cblas_icmax(n int, x voidptr, incx int) int
fn C.cblas_izmax(n int, x voidptr, incx int) int
fn C.cblas_ismin(n int, const_x &f32, incx int) int
fn C.cblas_idmin(n int, const_x &f64, incx int) int
fn C.cblas_icmin(n int, x voidptr, incx int) int
fn C.cblas_izmin(n int, x voidptr, incx int) int
fn C.cblas_saxpy(n int, alpha f32, const_x &f32, incx int, y &f32, incy int)
fn C.cblas_daxpy(n int, alpha f64, const_x &f64, incx int, y &f64, incy int)
fn C.cblas_caxpy(n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_zaxpy(n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int)
fn C.cblas_scopy(n int, const_x &f32, incx int, y &f32, incy int)
fn C.cblas_dcopy(n int, const_x &f64, incx int, y &f64, incy int)
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
fn C.cblas_srotm(n int, x &f32, incx int, y &f32, incy int, const_p &f32)
fn C.cblas_drotm(n int, x &f64, incx int, y &f64, incy int, const_p &f64)
fn C.cblas_srotmg(d1 &f32, d2 &f32, b1 &f32, b2 f32, p &f32)
fn C.cblas_drotmg(d1 &f64, d2 &f64, b1 &f64, b2 f64, p &f64)
fn C.cblas_sscal(n int, alpha f32, x &f32, incx int)
fn C.cblas_dscal(n int, alpha f64, x &f64, incx int)
fn C.cblas_cscal(n int, alpha voidptr, x voidptr, incx int)
fn C.cblas_zscal(n int, alpha voidptr, x voidptr, incx int)
fn C.cblas_csscal(n int, alpha f32, x voidptr, incx int)
fn C.cblas_zdscal(n int, alpha f64, x voidptr, incx int)
fn C.cblas_sgemv(order int, trans int, m int, n int, alpha f32, const_a &f32, lda int, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgemv(order int, trans int, m int, n int, alpha f64, const_a &f64, lda int, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgemv(order int, trans int, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgemv(order int, trans int, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sger(order int, m int, n int, alpha f32, const_x &f32, incx int, const_y &f32, incy int, a &f32, lda int)
fn C.cblas_dger(order int, m int, n int, alpha f64, const_x &f64, incx int, const_y &f64, incy int, a &f64, lda int)
fn C.cblas_cgeru(order int, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_cgerc(order int, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgeru(order int, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgerc(order int, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_strsv(order int, uplo int, transA int, diag int, n int, const_a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrsv(order int, uplo int, transA int, diag int, n int, const_a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrsv(order int, uplo int, transA int, diag int, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrsv(order int, uplo int, transA int, diag int, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_strmv(order int, uplo int, transA int, diag int, n int, const_a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrmv(order int, uplo int, transA int, diag int, n int, const_a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrmv(order int, uplo int, transA int, diag int, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrmv(order int, uplo int, transA int, diag int, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ssyr(order int, uplo int, n int, alpha f32, const_x &f32, incx int, a &f32, lda int)
fn C.cblas_dsyr(order int, uplo int, n int, alpha f64, const_x &f64, incx int, a &f64, lda int)
fn C.cblas_cher(order int, uplo int, n int, alpha f32, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_zher(order int, uplo int, n int, alpha f64, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_ssyr2(order int, uplo int, n int, alpha f32, const_x &f32, incx int, const_y &f32, incy int, a &f32, lda int)
fn C.cblas_dsyr2(order int, uplo int, n int, alpha f64, const_x &f64, incx int, const_y &f64, incy int, a &f64, lda int)
fn C.cblas_cher2(order int, uplo int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zher2(order int, uplo int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_sgbmv(order int, transA int, m int, n int, kl int, ku int, alpha f32, const_a &f32, lda int, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgbmv(order int, transA int, m int, n int, kl int, ku int, alpha f64, const_a &f64, lda int, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgbmv(order int, transA int, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgbmv(order int, transA int, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_ssbmv(order int, uplo int, n int, k int, alpha f32, const_a &f32, lda int, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsbmv(order int, uplo int, n int, k int, alpha f64, const_a &f64, lda int, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_stbmv(order int, uplo int, transA int, diag int, n int, k int, const_a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbmv(order int, uplo int, transA int, diag int, n int, k int, const_a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbmv(order int, uplo int, transA int, diag int, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbmv(order int, uplo int, transA int, diag int, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stbsv(order int, uplo int, transA int, diag int, n int, k int, const_a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbsv(order int, uplo int, transA int, diag int, n int, k int, const_a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbsv(order int, uplo int, transA int, diag int, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbsv(order int, uplo int, transA int, diag int, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stpmv(order int, uplo int, transA int, diag int, n int, const_ap &f32, x &f32, incx int)
fn C.cblas_dtpmv(order int, uplo int, transA int, diag int, n int, const_ap &f64, x &f64, incx int)
fn C.cblas_ctpmv(order int, uplo int, transA int, diag int, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpmv(order int, uplo int, transA int, diag int, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_stpsv(order int, uplo int, transA int, diag int, n int, const_ap &f32, x &f32, incx int)
fn C.cblas_dtpsv(order int, uplo int, transA int, diag int, n int, const_ap &f64, x &f64, incx int)
fn C.cblas_ctpsv(order int, uplo int, transA int, diag int, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpsv(order int, uplo int, transA int, diag int, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ssymv(order int, uplo int, n int, alpha f32, const_a &f32, lda int, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsymv(order int, uplo int, n int, alpha f64, const_a &f64, lda int, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_chemv(order int, uplo int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhemv(order int, uplo int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sspmv(order int, uplo int, n int, alpha f32, const_ap &f32, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dspmv(order int, uplo int, n int, alpha f64, const_ap &f64, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_sspr(order int, uplo int, n int, alpha f32, const_x &f32, incx int, ap &f32)
fn C.cblas_dspr(order int, uplo int, n int, alpha f64, const_x &f64, incx int, ap &f64)
fn C.cblas_chpr(order int, uplo int, n int, alpha f32, x voidptr, incx int, a voidptr)
fn C.cblas_zhpr(order int, uplo int, n int, alpha f64, x voidptr, incx int, a voidptr)
fn C.cblas_sspr2(order int, uplo int, n int, alpha f32, const_x &f32, incx int, const_y &f32, incy int, a &f32)
fn C.cblas_dspr2(order int, uplo int, n int, alpha f64, const_x &f64, incx int, const_y &f64, incy int, a &f64)
fn C.cblas_chpr2(order int, uplo int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_zhpr2(order int, uplo int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_chbmv(order int, uplo int, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhbmv(order int, uplo int, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_chpmv(order int, uplo int, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhpmv(order int, uplo int, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sgemm(order int, transA int, transB int, m int, n int, k int, alpha f32, const_a &f32, lda int, const_b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dgemm(order int, transA int, transB int, m int, n int, k int, alpha f64, const_a &f64, lda int, const_b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_cgemm(order int, transA int, transB int, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cgemm3m(order int, transA int, transB int, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm(order int, transA int, transB int, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm3m(order int, transA int, transB int, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssymm(order int, side int, uplo int, m int, n int, alpha f32, const_a &f32, lda int, const_b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsymm(order int, side int, uplo int, m int, n int, alpha f64, const_a &f64, lda int, const_b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csymm(order int, side int, uplo int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsymm(order int, side int, uplo int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyrk(order int, uplo int, trans int, n int, k int, alpha f32, const_a &f32, lda int, beta f32, c &f32, ldc int)
fn C.cblas_dsyrk(order int, uplo int, trans int, n int, k int, alpha f64, const_a &f64, lda int, beta f64, c &f64, ldc int)
fn C.cblas_csyrk(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyrk(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyr2k(order int, uplo int, trans int, n int, k int, alpha f32, const_a &f32, lda int, const_b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsyr2k(order int, uplo int, trans int, n int, k int, alpha f64, const_a &f64, lda int, const_b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csyr2k(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyr2k(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_strmm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha f32, const_a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrmm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha f64, const_a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrmm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrmm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_strsm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha f32, const_a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrsm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha f64, const_a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrsm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrsm(order int, side int, uplo int, transA int, diag int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_chemm(order int, side int, uplo int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zhemm(order int, side int, uplo int, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cherk(order int, uplo int, trans int, n int, k int, alpha f32, a voidptr, lda int, beta f32, c voidptr, ldc int)
fn C.cblas_zherk(order int, uplo int, trans int, n int, k int, alpha f64, a voidptr, lda int, beta f64, c voidptr, ldc int)
fn C.cblas_cher2k(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f32, c voidptr, ldc int)
fn C.cblas_zher2k(order int, uplo int, trans int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f64, c voidptr, ldc int)
fn C.cblas_xerbla(p int, rout &u8, form &u8, other voidptr)

fn C.cblas_saxpby(n int, alpha f32, const_x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_daxpby(n int, alpha f64, const_x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_caxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zaxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_somatcopy(corder int, ctrans int, crows int, ccols int, calpha f32, const_a &f32, clda int, b &f32, cldb int)
fn C.cblas_domatcopy(corder int, ctrans int, crows int, ccols int, calpha f64, const_a &f64, clda int, b &f64, cldb int)
fn C.cblas_comatcopy(corder int, ctrans int, crows int, ccols int, const_calpha &f32, const_a &f32, clda int, b &f32, cldb int)
fn C.cblas_zomatcopy(corder int, ctrans int, crows int, ccols int, const_calpha &f64, const_a &f64, clda int, b &f64, cldb int)
fn C.cblas_simatcopy(corder int, ctrans int, crows int, ccols int, calpha f32, a &f32, clda int, cldb int)
fn C.cblas_dimatcopy(corder int, ctrans int, crows int, ccols int, calpha f64, a &f64, clda int, cldb int)
fn C.cblas_cimatcopy(corder int, ctrans int, crows int, ccols int, calpha &f32, a &f32, clda int, cldb int)
fn C.cblas_zimatcopy(corder int, ctrans int, crows int, ccols int, calpha &f64, a &f64, clda int, cldb int)
fn C.cblas_sgeadd(corder int, crows int, ccols int, calpha f32, a &f32, clda int, cbeta f32, c &f32, cldc int)
fn C.cblas_dgeadd(corder int, crows int, ccols int, calpha f64, a &f64, clda int, cbeta f64, c &f64, cldc int)
fn C.cblas_cgeadd(corder int, crows int, ccols int, calpha &f32, a &f32, clda int, cbeta &f32, c &f32, cldc int)
fn C.cblas_zgeadd(corder int, crows int, ccols int, calpha &f64, a &f64, clda int, cbeta &f64, c &f64, cldc int)

// set_num_threads sets the number of threads in OpenBLAS
pub fn set_num_threads(n int) {
	C.openblas_set_num_threads(n)
}

@[inline]
pub fn sdsdot(n int, alpha f32, x []f32, incx int, y []f32, incy int) f32 {
	return C.cblas_sdsdot(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dsdot(n int, x []f32, incx int, y []f32, incy int) f64 {
	return C.cblas_dsdot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn sdot(n int, x []f32, incx int, y []f32, incy int) f32 {
	return C.cblas_sdot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas64.ddot(n, x, incx, y, incy)
}

@[inline]
pub fn sasum(n int, x []f32, incx int) f32 {
	return C.cblas_sasum(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	if n <= 0 || x.len == 0 {
		return 0.0
	}
	return blas64.dasum(n, x, incx)
}

@[inline]
pub fn scasum(n int, x voidptr, incx int) f32 {
	return C.cblas_scasum(n, x, incx)
}

@[inline]
pub fn dzasum(n int, x voidptr, incx int) f64 {
	return C.cblas_dzasum(n, x, incx)
}

@[inline]
pub fn ssum(n int, x []f32, incx int) f32 {
	return C.cblas_ssum(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dsum(n int, x []f64, incx int) f64 {
	return C.cblas_dsum(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn snrm2(n int, x []f32, incx int) f32 {
	return C.cblas_snrm2(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	if n <= 0 || x.len == 0 {
		return 0.0
	}
	return blas64.dnrm2(n, x, incx)
}

@[inline]
pub fn scnrm2(n int, x voidptr, incx int) f32 {
	return C.cblas_scnrm2(n, x, incx)
}

@[inline]
pub fn dznrm2(n int, x voidptr, incx int) f64 {
	return C.cblas_dznrm2(n, x, incx)
}

@[inline]
pub fn isamax(n int, x []f32, incx int) int {
	return C.cblas_isamax(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn idamax(n int, x []f64, incx int) int {
	return C.cblas_idamax(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn icamax(n int, x voidptr, incx int) int {
	return C.cblas_icamax(n, x, incx)
}

@[inline]
pub fn izamax(n int, x voidptr, incx int) int {
	return C.cblas_izamax(n, x, incx)
}

@[inline]
pub fn isamin(n int, x []f32, incx int) int {
	return C.cblas_isamin(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn idamin(n int, x []f64, incx int) int {
	return C.cblas_idamin(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn icamin(n int, x voidptr, incx int) int {
	return C.cblas_icamin(n, x, incx)
}

@[inline]
pub fn izamin(n int, x voidptr, incx int) int {
	return C.cblas_izamin(n, x, incx)
}

@[inline]
pub fn ismax(n int, x []f32, incx int) int {
	return C.cblas_ismax(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn idmax(n int, x []f64, incx int) int {
	return C.cblas_idmax(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn icmax(n int, x voidptr, incx int) int {
	return C.cblas_icmax(n, x, incx)
}

@[inline]
pub fn izmax(n int, x voidptr, incx int) int {
	return C.cblas_izmax(n, x, incx)
}

@[inline]
pub fn ismin(n int, x []f32, incx int) int {
	return C.cblas_ismin(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn idmin(n int, x []f64, incx int) int {
	return C.cblas_idmin(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn icmin(n int, x voidptr, incx int) int {
	return C.cblas_icmin(n, x, incx)
}

@[inline]
pub fn izmin(n int, x voidptr, incx int) int {
	return C.cblas_izmin(n, x, incx)
}

@[inline]
pub fn saxpy(n int, alpha f32, x []f32, incx int, mut y []f32, incy int) {
	C.cblas_saxpy(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	C.cblas_daxpy(n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn caxpy(n int, alpha voidptr, x voidptr, incx int, mut y voidptr, incy int) {
	C.cblas_caxpy(n, alpha, x, incx, y, incy)
}

@[inline]
pub fn zaxpy(n int, alpha voidptr, x voidptr, incx int, mut y voidptr, incy int) {
	C.cblas_zaxpy(n, alpha, x, incx, y, incy)
}

@[inline]
pub fn scopy(n int, x []f32, incx int, mut y []f32, incy int) {
	C.cblas_scopy(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	C.cblas_dcopy(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn ccopy(n int, x voidptr, incx int, mut y voidptr, incy int) {
	C.cblas_ccopy(n, x, incx, y, incy)
}

@[inline]
pub fn zcopy(n int, x voidptr, incx int, mut y voidptr, incy int) {
	C.cblas_zcopy(n, x, incx, y, incy)
}

@[inline]
pub fn sswap(n int, mut x []f32, incx int, mut y []f32, incy int) {
	C.cblas_sswap(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	C.cblas_dswap(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn cswap(n int, x voidptr, incx int, y voidptr, incy int) {
	C.cblas_cswap(n, x, incx, y, incy)
}

@[inline]
pub fn zswap(n int, x voidptr, incx int, y voidptr, incy int) {
	C.cblas_zswap(n, x, incx, y, incy)
}

@[inline]
pub fn srot(n int, mut x []f32, incx int, mut y []f32, incy int, c f32, s f32) {
	C.cblas_srot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, c, s)
}

@[inline]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	C.cblas_drot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, c, s)
}

@[inline]
pub fn srotg(a f32, b f32, c f32, s f32) {
	C.cblas_srotg(&a, &b, &c, &s)
}

@[inline]
pub fn drotg(a f64, b f64, c f64, s f64) {
	C.cblas_drotg(&a, &b, &c, &s)
}

@[inline]
pub fn srotm(n int, mut x []f32, incx int, mut y []f32, incy int, p []f32) {
	C.cblas_srotm(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, unsafe { &p[0] })
}

@[inline]
pub fn drotm(n int, mut x []f64, incx int, mut y []f64, incy int, p []f64) {
	C.cblas_drotm(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy, unsafe { &p[0] })
}

@[inline]
pub fn srotmg(d1 f32, d2 f32, b1 f32, b2 f32, mut p []f32) {
	C.cblas_srotmg(&d1, &d2, &b1, b2, unsafe { &p[0] })
}

@[inline]
pub fn drotmg(d1 f64, d2 f64, b1 f64, b2 f32, mut p []f64) {
	C.cblas_drotmg(&d1, &d2, &b1, b2, unsafe { &p[0] })
}

@[inline]
pub fn sscal(n int, alpha f32, mut x []f32, incx int) {
	C.cblas_sscal(n, alpha, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	C.cblas_dscal(n, alpha, unsafe { &x[0] }, incx)
}

@[inline]
pub fn cscal(n int, alpha voidptr, mut x voidptr, incx int) {
	C.cblas_cscal(n, alpha, x, incx)
}

@[inline]
pub fn zscal(n int, alpha voidptr, mut x voidptr, incx int) {
	C.cblas_zscal(n, alpha, x, incx)
}

@[inline]
pub fn csscal(n int, alpha f32, mut x voidptr, incx int) {
	C.cblas_csscal(n, alpha, x, incx)
}

@[inline]
pub fn zdscal(n int, alpha f64, mut x voidptr, incx int) {
	C.cblas_zdscal(n, alpha, x, incx)
}

@[inline]
pub fn sgemv(trans Transpose, m int, n int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sgemv(int(MemoryLayout.row_major), int(trans), m, n, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dgemv(int(MemoryLayout.row_major), int(trans), m, n, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn cgemv(trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_cgemv(int(MemoryLayout.row_major), int(trans), m, n, alpha, a, lda, x, incx, beta, y,
		incy)
}

@[inline]
pub fn zgemv(trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zgemv(int(MemoryLayout.row_major), int(trans), m, n, alpha, a, lda, x, incx, beta, y,
		incy)
}

@[inline]
pub fn sger(m int, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32, lda int) {
	C.cblas_sger(int(MemoryLayout.row_major), m, n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	C.cblas_dger(int(MemoryLayout.row_major), m, n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn cgeru(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cgeru(int(MemoryLayout.row_major), m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn cgerc(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cgerc(int(MemoryLayout.row_major), m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zgeru(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zgeru(int(MemoryLayout.row_major), m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zgerc(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zgerc(int(MemoryLayout.row_major), m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn strsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_strsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtrsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctrsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, a, lda, x, incx)
}

@[inline]
pub fn ztrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztrsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, a, lda, x, incx)
}

@[inline]
pub fn strmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_strmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtrmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctrmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, a, lda, x, incx)
}

@[inline]
pub fn ztrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztrmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, a, lda, x, incx)
}

@[inline]
pub fn ssyr(uplo Uplo, n int, alpha f32, x []f32, incx int, mut a []f32, lda int) {
	C.cblas_ssyr(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &a[0] }, lda)
}

@[inline]
pub fn dsyr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	C.cblas_dsyr(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &a[0] }, lda)
}

@[inline]
pub fn cher(uplo Uplo, n int, alpha f32, x voidptr, incx int, mut a voidptr, lda int) {
	C.cblas_cher(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, a, lda)
}

@[inline]
pub fn zher(uplo Uplo, n int, alpha f64, x voidptr, incx int, mut a voidptr, lda int) {
	C.cblas_zher(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, a, lda)
}

@[inline]
pub fn ssyr2(uplo Uplo, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32, lda int) {
	C.cblas_ssyr2(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn dsyr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	C.cblas_dsyr2(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn cher2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cher2(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zher2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zher2(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn sgbmv(trans Transpose, m int, n int, kl int, ku int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sgbmv(int(MemoryLayout.row_major), int(trans), m, n, kl, ku, alpha, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dgbmv(trans Transpose, m int, n int, kl int, ku int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dgbmv(int(MemoryLayout.row_major), int(trans), m, n, kl, ku, alpha, unsafe { &a[0] },
		lda, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn cgbmv(trans Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_cgbmv(int(MemoryLayout.row_major), int(trans), m, n, kl, ku, alpha, a, lda, x, incx,
		beta, y, incy)
}

@[inline]
pub fn zgbmv(trans Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zgbmv(int(MemoryLayout.row_major), int(trans), m, n, kl, ku, alpha, a, lda, x, incx,
		beta, y, incy)
}

@[inline]
pub fn ssbmv(uplo Uplo, n int, k int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_ssbmv(int(MemoryLayout.row_major), int(uplo), n, k, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dsbmv(uplo Uplo, n int, k int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dsbmv(int(MemoryLayout.row_major), int(uplo), n, k, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn stbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_stbmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtbmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctbmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k, a, lda, x,
		incx)
}

@[inline]
pub fn ztbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztbmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k, a, lda, x,
		incx)
}

@[inline]
pub fn stbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_stbsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtbsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k,
		unsafe { &a[0] }, lda, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctbsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k, a, lda, x,
		incx)
}

@[inline]
pub fn ztbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztbsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, k, a, lda, x,
		incx)
}

@[inline]
pub fn stpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f32, mut x []f32, incx int) {
	C.cblas_stpmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &ap[0] }, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	C.cblas_dtpmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &ap[0] }, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ctpmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, ap, x, incx)
}

@[inline]
pub fn ztpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ztpmv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, ap, x, incx)
}

@[inline]
pub fn stpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f32, mut x []f32, incx int) {
	C.cblas_stpsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &ap[0] }, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dtpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	C.cblas_dtpsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n,
		unsafe { &ap[0] }, unsafe { &x[0] }, incx)
}

@[inline]
pub fn ctpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ctpsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, ap, x, incx)
}

@[inline]
pub fn ztpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ztpsv(int(MemoryLayout.row_major), int(uplo), int(trans), int(diag), n, ap, x, incx)
}

@[inline]
pub fn ssymv(uplo Uplo, n int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_ssymv(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dsymv(uplo Uplo, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dsymv(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &a[0] }, lda,
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn chemv(uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chemv(int(MemoryLayout.row_major), int(uplo), n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn zhemv(uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhemv(int(MemoryLayout.row_major), int(uplo), n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn sspmv(uplo Uplo, n int, alpha f32, ap []f32, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sspmv(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &ap[0] },
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dspmv(uplo Uplo, n int, alpha f64, ap []f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dspmv(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &ap[0] },
		unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn sspr(uplo Uplo, n int, alpha f32, x []f32, incx int, mut ap []f32) {
	C.cblas_sspr(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &ap[0] })
}

@[inline]
pub fn dspr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut ap []f64) {
	C.cblas_dspr(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &ap[0] })
}

@[inline]
pub fn chpr(uplo Uplo, n int, alpha f32, x voidptr, incx int, mut a voidptr) {
	C.cblas_chpr(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, a)
}

@[inline]
pub fn zhpr(uplo Uplo, n int, alpha f64, x voidptr, incx int, mut a voidptr) {
	C.cblas_zhpr(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, a)
}

@[inline]
pub fn sspr2(uplo Uplo, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32) {
	C.cblas_sspr2(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] })
}

@[inline]
pub fn dspr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64) {
	C.cblas_dspr2(int(MemoryLayout.row_major), int(uplo), n, alpha, unsafe { &x[0] }, incx,
		unsafe { &y[0] }, incy, unsafe { &a[0] })
}

@[inline]
pub fn chpr2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut ap voidptr) {
	C.cblas_chpr2(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, y, incy, ap)
}

@[inline]
pub fn zhpr2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut ap voidptr) {
	C.cblas_zhpr2(int(MemoryLayout.row_major), int(uplo), n, alpha, x, incx, y, incy, ap)
}

@[inline]
pub fn chbmv(uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chbmv(int(MemoryLayout.row_major), int(uplo), n, k, alpha, a, lda, x, incx, beta, y,
		incy)
}

@[inline]
pub fn zhbmv(uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhbmv(int(MemoryLayout.row_major), int(uplo), n, k, alpha, a, lda, x, incx, beta, y,
		incy)
}

@[inline]
pub fn chpmv(uplo Uplo, n int, alpha voidptr, ap voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chpmv(int(MemoryLayout.row_major), int(uplo), n, alpha, ap, x, incx, beta, y, incy)
}

@[inline]
pub fn zhpmv(uplo Uplo, n int, alpha voidptr, ap voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhpmv(int(MemoryLayout.row_major), int(uplo), n, alpha, ap, x, incx, beta, y, incy)
}

@[inline]
pub fn ssyrk(uplo Uplo, trans Transpose, n int, k int, alpha f32, a []f32, lda int, beta f32, mut c []f32, ldc int) {
	C.cblas_ssyrk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha,
		unsafe { &a[0] }, lda, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn dsyrk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	C.cblas_dsyrk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha,
		unsafe { &a[0] }, lda, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn csyrk(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_csyrk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, beta, c,
		ldc)
}

@[inline]
pub fn zsyrk(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zsyrk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, beta, c,
		ldc)
}

@[inline]
pub fn ssyr2k(uplo Uplo, trans Transpose, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	C.cblas_ssyr2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha,
		unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn dsyr2k(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	C.cblas_dsyr2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha,
		unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn csyr2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_csyr2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn zsyr2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zsyr2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn strmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f32, a []f32, lda int, mut b []f32, ldb int) {
	C.cblas_strmm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn dtrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_dtrmm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn ctrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ctrmm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, a, lda, b, ldb)
}

@[inline]
pub fn ztrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ztrmm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, a, lda, b, ldb)
}

@[inline]
pub fn strsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f32, a []f32, lda int, mut b []f32, ldb int) {
	C.cblas_strsm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn dtrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_dtrsm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn ctrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ctrsm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, a, lda, b, ldb)
}

@[inline]
pub fn ztrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ztrsm(int(MemoryLayout.row_major), int(side), int(uplo), int(trans), int(diag), m, n,
		alpha, a, lda, b, ldb)
}

@[inline]
pub fn chemm(side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_chemm(int(MemoryLayout.row_major), int(side), int(uplo), m, n, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn zhemm(side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zhemm(int(MemoryLayout.row_major), int(side), int(uplo), m, n, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn cherk(uplo Uplo, trans Transpose, n int, k int, alpha f32, a voidptr, lda int, beta f32, mut c voidptr, ldc int) {
	C.cblas_cherk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, beta, c,
		ldc)
}

@[inline]
pub fn zherk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a voidptr, lda int, beta f64, mut c voidptr, ldc int) {
	C.cblas_zherk(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, beta, c,
		ldc)
}

@[inline]
pub fn cher2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta f32, mut c voidptr, ldc int) {
	C.cblas_cher2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn zher2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta f64, mut c voidptr, ldc int) {
	C.cblas_zher2k(int(MemoryLayout.row_major), int(uplo), int(trans), n, k, alpha, a, lda, b, ldb,
		beta, c, ldc)
}

@[inline]
pub fn saxpby(n int, alpha f32, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_saxpby(n, alpha, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn daxpby(n int, alpha f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_daxpby(n, alpha, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn caxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_caxpby(n, alpha, x, incx, beta, y, incy)
}

@[inline]
pub fn zaxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zaxpby(n, alpha, x, incx, beta, y, incy)
}

@[inline]
pub fn somatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f32, a []f32, lda int, mut b []f32, ldb int) {
	C.cblas_somatcopy(int(order), int(trans), rows, cols, alpha, unsafe { &a[0] }, lda,
		unsafe { &b[0] }, ldb)
}

@[inline]
pub fn domatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_domatcopy(int(order), int(trans), rows, cols, alpha, unsafe { &a[0] }, lda,
		unsafe { &b[0] }, ldb)
}

@[inline]
pub fn comatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f32, a &f32, lda int, mut b &f32, ldb int) {
	C.cblas_comatcopy(int(order), int(trans), rows, cols, alpha, a, lda, b, ldb)
}

@[inline]
pub fn zomatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f64, a &f64, lda int, mut b &f64, ldb int) {
	C.cblas_zomatcopy(int(order), int(trans), rows, cols, alpha, a, lda, b, ldb)
}

@[inline]
pub fn simatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f32, mut a []f32, lda int, ldb int) {
	C.cblas_simatcopy(int(order), int(trans), rows, cols, alpha, unsafe { &a[0] }, lda, ldb)
}

@[inline]
pub fn dimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f64, mut a []f64, lda int, ldb int) {
	C.cblas_dimatcopy(int(order), int(trans), rows, cols, alpha, unsafe { &a[0] }, lda, ldb)
}

@[inline]
pub fn cimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f32, mut a &f32, lda int, ldb int) {
	C.cblas_cimatcopy(int(order), int(trans), rows, cols, alpha, a, lda, ldb)
}

@[inline]
pub fn zimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f64, mut a &f64, lda int, ldb int) {
	C.cblas_zimatcopy(int(order), int(trans), rows, cols, alpha, a, lda, ldb)
}

@[inline]
pub fn sgeadd(order MemoryLayout, rows int, cols int, alpha f32, a []f32, lda int, beta f32, mut c []f32, ldc int) {
	C.cblas_sgeadd(int(order), rows, cols, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn dgeadd(order MemoryLayout, rows int, cols int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	C.cblas_dgeadd(int(order), rows, cols, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn cgeadd(order MemoryLayout, rows int, cols int, alpha &f32, a &f32, lda int, beta &f32, mut c &f32, ldc int) {
	C.cblas_cgeadd(int(order), rows, cols, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn zgeadd(order MemoryLayout, rows int, cols int, alpha &f64, a &f64, lda int, beta &f64, mut c &f64, ldc int) {
	C.cblas_zgeadd(int(order), rows, cols, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	C.cblas_dgemm(int(MemoryLayout.row_major), int(trans_a), int(trans_b), m, n, k, alpha,
		unsafe { &a[0] }, lda, unsafe { &b[0] }, ldb, beta, unsafe { &cc[0] }, ldc)
}
