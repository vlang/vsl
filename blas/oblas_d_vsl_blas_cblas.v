module blas

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
fn C.cblas_sgemv(order MemoryLayout, trans Transpose, m int, n int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgemv(order MemoryLayout, trans Transpose, m int, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgemv(order MemoryLayout, trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgemv(order MemoryLayout, trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sger(order MemoryLayout, m int, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32, lda int)
fn C.cblas_dger(order MemoryLayout, m int, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)
fn C.cblas_cgeru(order MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_cgerc(order MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgeru(order MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zgerc(order MemoryLayout, m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_strsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_strmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtrmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctrmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztrmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ssyr(order MemoryLayout, uplo Uplo, n int, alpha f32, x &f32, incx int, a &f32, lda int)
fn C.cblas_dsyr(order MemoryLayout, uplo Uplo, n int, alpha f64, x &f64, incx int, a &f64, lda int)
fn C.cblas_cher(order MemoryLayout, uplo Uplo, n int, alpha f32, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_zher(order MemoryLayout, uplo Uplo, n int, alpha f64, x voidptr, incx int, a voidptr, lda int)
fn C.cblas_ssyr2(order MemoryLayout, uplo Uplo, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32, lda int)
fn C.cblas_dsyr2(order MemoryLayout, uplo Uplo, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)
fn C.cblas_cher2(order MemoryLayout, uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_zher2(order MemoryLayout, uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, a voidptr, lda int)
fn C.cblas_sgbmv(order MemoryLayout, transA Transpose, m int, n int, kl int, ku int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dgbmv(order MemoryLayout, transA Transpose, m int, n int, kl int, ku int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_cgbmv(order MemoryLayout, transA Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zgbmv(order MemoryLayout, transA Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_ssbmv(order MemoryLayout, uplo Uplo, n int, k int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsbmv(order MemoryLayout, uplo Uplo, n int, k int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_stbmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stbsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a &f32, lda int, x &f32, incx int)
fn C.cblas_dtbsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a &f64, lda int, x &f64, incx int)
fn C.cblas_ctbsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_ztbsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, k int, a voidptr, lda int, x voidptr, incx int)
fn C.cblas_stpmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap &f32, x &f32, incx int)
fn C.cblas_dtpmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap &f64, x &f64, incx int)
fn C.cblas_ctpmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpmv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_stpsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap &f32, x &f32, incx int)
fn C.cblas_dtpsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap &f64, x &f64, incx int)
fn C.cblas_ctpsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ztpsv(order MemoryLayout, uplo Uplo, transA Transpose, diag Diagonal, n int, ap voidptr, x voidptr, incx int)
fn C.cblas_ssymv(order MemoryLayout, uplo Uplo, n int, alpha f32, a &f32, lda int, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dsymv(order MemoryLayout, uplo Uplo, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_chemv(order MemoryLayout, uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhemv(order MemoryLayout, uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sspmv(order MemoryLayout, uplo Uplo, n int, alpha f32, ap &f32, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_dspmv(order MemoryLayout, uplo Uplo, n int, alpha f64, ap &f64, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_sspr(order MemoryLayout, uplo Uplo, n int, alpha f32, x &f32, incx int, ap &f32)
fn C.cblas_dspr(order MemoryLayout, uplo Uplo, n int, alpha f64, x &f64, incx int, ap &f64)
fn C.cblas_chpr(order MemoryLayout, uplo Uplo, n int, alpha f32, x voidptr, incx int, a voidptr)
fn C.cblas_zhpr(order MemoryLayout, uplo Uplo, n int, alpha f64, x voidptr, incx int, a voidptr)
fn C.cblas_sspr2(order MemoryLayout, uplo Uplo, n int, alpha f32, x &f32, incx int, y &f32, incy int, a &f32)
fn C.cblas_dspr2(order MemoryLayout, uplo Uplo, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64)
fn C.cblas_chpr2(order MemoryLayout, uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_zhpr2(order MemoryLayout, uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, AP voidptr)
fn C.cblas_chbmv(order MemoryLayout, uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhbmv(order MemoryLayout, uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_chpmv(order MemoryLayout, uplo Uplo, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zhpmv(order MemoryLayout, uplo Uplo, n int, alpha voidptr, AP voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_sgemm(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dgemm(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_cgemm(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cgemm3m(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zgemm3m(order MemoryLayout, transA Transpose, transB Transpose, m int, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssymm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsymm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csymm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsymm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyrk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f32, a &f32, lda int, beta f32, c &f32, ldc int)
fn C.cblas_dsyrk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f64, a &f64, lda int, beta f64, c &f64, ldc int)
fn C.cblas_csyrk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyrk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, c voidptr, ldc int)
fn C.cblas_ssyr2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f32, a &f32, lda int, b &f32, ldb int, beta f32, c &f32, ldc int)
fn C.cblas_dsyr2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, beta f64, c &f64, ldc int)
fn C.cblas_csyr2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zsyr2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_strmm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrmm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrmm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrmm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_strsm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha f32, a &f32, lda int, b &f32, ldb int)
fn C.cblas_dtrsm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha f64, a &f64, lda int, b &f64, ldb int)
fn C.cblas_ctrsm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_ztrsm(order MemoryLayout, side Side, uplo Uplo, transA Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int)
fn C.cblas_chemm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_zhemm(order MemoryLayout, side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta voidptr, c voidptr, ldc int)
fn C.cblas_cherk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f32, a voidptr, lda int, beta f32, c voidptr, ldc int)
fn C.cblas_zherk(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha f64, a voidptr, lda int, beta f64, c voidptr, ldc int)
fn C.cblas_cher2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f32, c voidptr, ldc int)
fn C.cblas_zher2k(order MemoryLayout, uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, B voidptr, ldb int, beta f64, c voidptr, ldc int)
fn C.cblas_xerbla(p int, rout &byte, form &byte, other voidptr)

fn C.cblas_saxpby(n int, alpha f32, x &f32, incx int, beta f32, y &f32, incy int)
fn C.cblas_daxpby(n int, alpha f64, x &f64, incx int, beta f64, y &f64, incy int)
fn C.cblas_caxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_zaxpby(n int, alpha voidptr, x voidptr, incx int, beta voidptr, y voidptr, incy int)
fn C.cblas_somatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha f32, a &f32, clda int, b &f32, cldb int)
fn C.cblas_domatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha f64, a &f64, clda int, b &f64, cldb int)
fn C.cblas_comatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha &f32, a &f32, clda int, b &f32, cldb int)
fn C.cblas_zomatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha &f64, a &f64, clda int, b &f64, cldb int)
fn C.cblas_simatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha f32, a &f32, clda int, cldb int)
fn C.cblas_dimatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha f64, a &f64, clda int, cldb int)
fn C.cblas_cimatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha &f32, a &f32, clda int, cldb int)
fn C.cblas_zimatcopy(corder MemoryLayout, ctrans Transpose, crows int, ccols int, calpha &f64, a &f64, clda int, cldb int)
fn C.cblas_sgeadd(corder MemoryLayout, crows int, ccols int, calpha f32, a &f32, clda int, cbeta f32, c &f32, cldc int)
fn C.cblas_dgeadd(corder MemoryLayout, crows int, ccols int, calpha f64, a &f64, clda int, cbeta f64, c &f64, cldc int)
fn C.cblas_cgeadd(corder MemoryLayout, crows int, ccols int, calpha &f32, a &f32, clda int, cbeta &f32, c &f32, cldc int)
fn C.cblas_zgeadd(corder MemoryLayout, crows int, ccols int, calpha &f64, a &f64, clda int, cbeta &f64, c &f64, cldc int)

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
	return C.cblas_ddot(n, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy)
}

@[inline]
pub fn sasum(n int, x []f32, incx int) f32 {
	return C.cblas_sasum(n, unsafe { &x[0] }, incx)
}

@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return C.cblas_dasum(n, unsafe { &x[0] }, incx)
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
	return C.cblas_dnrm2(n, unsafe { &x[0] }, incx)
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
	C.cblas_sgemv(.row_major, trans, m, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dgemv(.row_major, trans, m, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn cgemv(trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_cgemv(.row_major, trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn zgemv(trans Transpose, m int, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zgemv(.row_major, trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn sger(m int, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32, lda int) {
	C.cblas_sger(.row_major, m, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy,
		unsafe { &a[0] }, lda)
}

@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	C.cblas_dger(.row_major, m, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] }, incy,
		unsafe { &a[0] }, lda)
}

@[inline]
pub fn cgeru(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cgeru(.row_major, m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn cgerc(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cgerc(.row_major, m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zgeru(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zgeru(.row_major, m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zgerc(m int, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zgerc(.row_major, m, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn strsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_strsv(.row_major, uplo, trans, diag, n, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtrsv(.row_major, uplo, trans, diag, n, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctrsv(.row_major, uplo, trans, diag, n, a, lda, x, incx)
}

@[inline]
pub fn ztrsv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztrsv(.row_major, uplo, trans, diag, n, a, lda, x, incx)
}

@[inline]
pub fn strmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_strmv(.row_major, uplo, trans, diag, n, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtrmv(.row_major, uplo, trans, diag, n, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctrmv(.row_major, uplo, trans, diag, n, a, lda, x, incx)
}

@[inline]
pub fn ztrmv(uplo Uplo, trans Transpose, diag Diagonal, n int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztrmv(.row_major, uplo, trans, diag, n, a, lda, x, incx)
}

@[inline]
pub fn ssyr(uplo Uplo, n int, alpha f32, x []f32, incx int, mut a []f32, lda int) {
	C.cblas_ssyr(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &a[0] },
		lda)
}

@[inline]
pub fn dsyr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	C.cblas_dsyr(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &a[0] },
		lda)
}

@[inline]
pub fn cher(uplo Uplo, n int, alpha f32, x voidptr, incx int, mut a voidptr, lda int) {
	C.cblas_cher(.row_major, uplo, n, alpha, x, incx, a, lda)
}

@[inline]
pub fn zher(uplo Uplo, n int, alpha f64, x voidptr, incx int, mut a voidptr, lda int) {
	C.cblas_zher(.row_major, uplo, n, alpha, x, incx, a, lda)
}

@[inline]
pub fn ssyr2(uplo Uplo, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32, lda int) {
	C.cblas_ssyr2(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn dsyr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	C.cblas_dsyr2(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] }, lda)
}

@[inline]
pub fn cher2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_cher2(.row_major, uplo, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn zher2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut a voidptr, lda int) {
	C.cblas_zher2(.row_major, uplo, n, alpha, x, incx, y, incy, a, lda)
}

@[inline]
pub fn sgbmv(trans Transpose, m int, n int, kl int, ku int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sgbmv(.row_major, trans, m, n, kl, ku, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dgbmv(trans Transpose, m int, n int, kl int, ku int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dgbmv(.row_major, trans, m, n, kl, ku, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn cgbmv(trans Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_cgbmv(.row_major, trans, m, n, kl, ku, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn zgbmv(trans Transpose, m int, n int, kl int, ku int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zgbmv(.row_major, trans, m, n, kl, ku, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn ssbmv(uplo Uplo, n int, k int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_ssbmv(.row_major, uplo, n, k, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dsbmv(uplo Uplo, n int, k int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dsbmv(.row_major, uplo, n, k, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn stbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_stbmv(.row_major, uplo, trans, diag, n, k, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtbmv(.row_major, uplo, trans, diag, n, k, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctbmv(.row_major, uplo, trans, diag, n, k, a, lda, x, incx)
}

@[inline]
pub fn ztbmv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztbmv(.row_major, uplo, trans, diag, n, k, a, lda, x, incx)
}

@[inline]
pub fn stbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f32, lda int, mut x []f32, incx int) {
	C.cblas_stbsv(.row_major, uplo, trans, diag, n, k, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	C.cblas_dtbsv(.row_major, uplo, trans, diag, n, k, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ctbsv(.row_major, uplo, trans, diag, n, k, a, lda, x, incx)
}

@[inline]
pub fn ztbsv(uplo Uplo, trans Transpose, diag Diagonal, n int, k int, a voidptr, lda int, mut x voidptr, incx int) {
	C.cblas_ztbsv(.row_major, uplo, trans, diag, n, k, a, lda, x, incx)
}

@[inline]
pub fn stpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f32, mut x []f32, incx int) {
	C.cblas_stpmv(.row_major, uplo, trans, diag, n, unsafe { &ap[0] }, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	C.cblas_dtpmv(.row_major, uplo, trans, diag, n, unsafe { &ap[0] }, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ctpmv(.row_major, uplo, trans, diag, n, ap, x, incx)
}

@[inline]
pub fn ztpmv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ztpmv(.row_major, uplo, trans, diag, n, ap, x, incx)
}

@[inline]
pub fn stpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f32, mut x []f32, incx int) {
	C.cblas_stpsv(.row_major, uplo, trans, diag, n, unsafe { &ap[0] }, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn dtpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	C.cblas_dtpsv(.row_major, uplo, trans, diag, n, unsafe { &ap[0] }, unsafe { &x[0] },
		incx)
}

@[inline]
pub fn ctpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ctpsv(.row_major, uplo, trans, diag, n, ap, x, incx)
}

@[inline]
pub fn ztpsv(uplo Uplo, trans Transpose, diag Diagonal, n int, ap voidptr, mut x voidptr, incx int) {
	C.cblas_ztpsv(.row_major, uplo, trans, diag, n, ap, x, incx)
}

@[inline]
pub fn ssymv(uplo Uplo, n int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_ssymv(.row_major, uplo, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dsymv(uplo Uplo, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dsymv(.row_major, uplo, n, alpha, unsafe { &a[0] }, lda, unsafe { &x[0] },
		incx, beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn chemv(uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chemv(.row_major, uplo, n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn zhemv(uplo Uplo, n int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhemv(.row_major, uplo, n, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn sspmv(uplo Uplo, n int, alpha f32, ap []f32, x []f32, incx int, beta f32, mut y []f32, incy int) {
	C.cblas_sspmv(.row_major, uplo, n, alpha, unsafe { &ap[0] }, unsafe { &x[0] }, incx,
		beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn dspmv(uplo Uplo, n int, alpha f64, ap []f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	C.cblas_dspmv(.row_major, uplo, n, alpha, unsafe { &ap[0] }, unsafe { &x[0] }, incx,
		beta, unsafe { &y[0] }, incy)
}

@[inline]
pub fn sspr(uplo Uplo, n int, alpha f32, x []f32, incx int, mut ap []f32) {
	C.cblas_sspr(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &ap[0] })
}

@[inline]
pub fn dspr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut ap []f64) {
	C.cblas_dspr(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &ap[0] })
}

@[inline]
pub fn chpr(uplo Uplo, n int, alpha f32, x voidptr, incx int, mut a voidptr) {
	C.cblas_chpr(.row_major, uplo, n, alpha, x, incx, a)
}

@[inline]
pub fn zhpr(uplo Uplo, n int, alpha f64, x voidptr, incx int, mut a voidptr) {
	C.cblas_zhpr(.row_major, uplo, n, alpha, x, incx, a)
}

@[inline]
pub fn sspr2(uplo Uplo, n int, alpha f32, x []f32, incx int, y []f32, incy int, mut a []f32) {
	C.cblas_sspr2(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] })
}

@[inline]
pub fn dspr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64) {
	C.cblas_dspr2(.row_major, uplo, n, alpha, unsafe { &x[0] }, incx, unsafe { &y[0] },
		incy, unsafe { &a[0] })
}

@[inline]
pub fn chpr2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut ap voidptr) {
	C.cblas_chpr2(.row_major, uplo, n, alpha, x, incx, y, incy, ap)
}

@[inline]
pub fn zhpr2(uplo Uplo, n int, alpha voidptr, x voidptr, incx int, y voidptr, incy int, mut ap voidptr) {
	C.cblas_zhpr2(.row_major, uplo, n, alpha, x, incx, y, incy, ap)
}

@[inline]
pub fn chbmv(uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chbmv(.row_major, uplo, n, k, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn zhbmv(uplo Uplo, n int, k int, alpha voidptr, a voidptr, lda int, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhbmv(.row_major, uplo, n, k, alpha, a, lda, x, incx, beta, y, incy)
}

@[inline]
pub fn chpmv(uplo Uplo, n int, alpha voidptr, ap voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_chpmv(.row_major, uplo, n, alpha, ap, x, incx, beta, y, incy)
}

@[inline]
pub fn zhpmv(uplo Uplo, n int, alpha voidptr, ap voidptr, x voidptr, incx int, beta voidptr, mut y voidptr, incy int) {
	C.cblas_zhpmv(.row_major, uplo, n, alpha, ap, x, incx, beta, y, incy)
}

@[inline]
pub fn ssyrk(uplo Uplo, trans Transpose, n int, k int, alpha f32, a []f32, lda int, beta f32, mut c []f32, ldc int) {
	C.cblas_ssyrk(.row_major, uplo, trans, n, k, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn dsyrk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	C.cblas_dsyrk(.row_major, uplo, trans, n, k, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn csyrk(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_csyrk(.row_major, uplo, trans, n, k, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn zsyrk(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zsyrk(.row_major, uplo, trans, n, k, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn ssyr2k(uplo Uplo, trans Transpose, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	C.cblas_ssyr2k(.row_major, uplo, trans, n, k, alpha, unsafe { &a[0] }, lda, unsafe { &b[0] },
		ldb, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn dsyr2k(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	C.cblas_dsyr2k(.row_major, uplo, trans, n, k, alpha, unsafe { &a[0] }, lda, unsafe { &b[0] },
		ldb, beta, unsafe { &c[0] }, ldc)
}

@[inline]
pub fn csyr2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_csyr2k(.row_major, uplo, trans, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
}

@[inline]
pub fn zsyr2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zsyr2k(.row_major, uplo, trans, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
}

@[inline]
pub fn strmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f32, a []f32, lda int, mut b []f32, ldb int) {
	C.cblas_strmm(.row_major, side, uplo, trans, diag, m, n, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn dtrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_dtrmm(.row_major, side, uplo, trans, diag, m, n, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn ctrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ctrmm(.row_major, side, uplo, trans, diag, m, n, alpha, a, lda, b, ldb)
}

@[inline]
pub fn ztrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ztrmm(.row_major, side, uplo, trans, diag, m, n, alpha, a, lda, b, ldb)
}

@[inline]
pub fn strsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f32, a []f32, lda int, mut b []f32, ldb int) {
	C.cblas_strsm(.row_major, side, uplo, trans, diag, m, n, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn dtrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_dtrsm(.row_major, side, uplo, trans, diag, m, n, alpha, unsafe { &a[0] },
		lda, unsafe { &b[0] }, ldb)
}

@[inline]
pub fn ctrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ctrsm(.row_major, side, uplo, trans, diag, m, n, alpha, a, lda, b, ldb)
}

@[inline]
pub fn ztrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha voidptr, a voidptr, lda int, mut b voidptr, ldb int) {
	C.cblas_ztrsm(.row_major, side, uplo, trans, diag, m, n, alpha, a, lda, b, ldb)
}

@[inline]
pub fn chemm(side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_chemm(.row_major, side, uplo, m, n, alpha, a, lda, b, ldb, beta, c, ldc)
}

@[inline]
pub fn zhemm(side Side, uplo Uplo, m int, n int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta voidptr, mut c voidptr, ldc int) {
	C.cblas_zhemm(.row_major, side, uplo, m, n, alpha, a, lda, b, ldb, beta, c, ldc)
}

@[inline]
pub fn cherk(uplo Uplo, trans Transpose, n int, k int, alpha f32, a voidptr, lda int, beta f32, mut c voidptr, ldc int) {
	C.cblas_cherk(.row_major, uplo, trans, n, k, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn zherk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a voidptr, lda int, beta f64, mut c voidptr, ldc int) {
	C.cblas_zherk(.row_major, uplo, trans, n, k, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn cher2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta f32, mut c voidptr, ldc int) {
	C.cblas_cher2k(.row_major, uplo, trans, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
}

@[inline]
pub fn zher2k(uplo Uplo, trans Transpose, n int, k int, alpha voidptr, a voidptr, lda int, b voidptr, ldb int, beta f64, mut c voidptr, ldc int) {
	C.cblas_zher2k(.row_major, uplo, trans, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
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
	C.cblas_somatcopy(order, trans, rows, cols, alpha, unsafe { &a[0] }, lda, unsafe { &b[0] },
		ldb)
}

@[inline]
pub fn domatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	C.cblas_domatcopy(order, trans, rows, cols, alpha, unsafe { &a[0] }, lda, unsafe { &b[0] },
		ldb)
}

@[inline]
pub fn comatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f32, a &f32, lda int, mut b &f32, ldb int) {
	C.cblas_comatcopy(order, trans, rows, cols, alpha, a, lda, b, ldb)
}

@[inline]
pub fn zomatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f64, a &f64, lda int, mut b &f64, ldb int) {
	C.cblas_zomatcopy(order, trans, rows, cols, alpha, a, lda, b, ldb)
}

@[inline]
pub fn simatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f32, mut a []f32, lda int, ldb int) {
	C.cblas_simatcopy(order, trans, rows, cols, alpha, unsafe { &a[0] }, lda, ldb)
}

@[inline]
pub fn dimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha f64, mut a []f64, lda int, ldb int) {
	C.cblas_dimatcopy(order, trans, rows, cols, alpha, unsafe { &a[0] }, lda, ldb)
}

@[inline]
pub fn cimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f32, mut a &f32, lda int, ldb int) {
	C.cblas_cimatcopy(order, trans, rows, cols, alpha, a, lda, ldb)
}

@[inline]
pub fn zimatcopy(order MemoryLayout, trans Transpose, rows int, cols int, alpha &f64, mut a &f64, lda int, ldb int) {
	C.cblas_zimatcopy(order, trans, rows, cols, alpha, a, lda, ldb)
}

@[inline]
pub fn sgeadd(order MemoryLayout, rows int, cols int, alpha f32, a []f32, lda int, beta f32, mut c []f32, ldc int) {
	C.cblas_sgeadd(order, rows, cols, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn dgeadd(order MemoryLayout, rows int, cols int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	C.cblas_dgeadd(order, rows, cols, alpha, unsafe { &a[0] }, lda, beta, unsafe { &c[0] },
		ldc)
}

@[inline]
pub fn cgeadd(order MemoryLayout, rows int, cols int, alpha &f32, a &f32, lda int, beta &f32, mut c &f32, ldc int) {
	C.cblas_cgeadd(order, rows, cols, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn zgeadd(order MemoryLayout, rows int, cols int, alpha &f64, a &f64, lda int, beta &f64, mut c &f64, ldc int) {
	C.cblas_zgeadd(order, rows, cols, alpha, a, lda, beta, c, ldc)
}

@[inline]
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	C.cblas_dgemm(.row_major, trans_a, trans_b, m, n, k, alpha, unsafe { &a[0] }, lda,
		unsafe { &b[0] }, ldb, beta, unsafe { &cc[0] }, ldc)
}
