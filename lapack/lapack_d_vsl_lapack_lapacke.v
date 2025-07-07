module lapack

import vsl.errors
import vsl.blas

fn C.LAPACKE_dgesv(matrix_layout blas.MemoryLayout, n int, nrhs int, a &f64, lda int, ipiv &int, b &f64, ldb int) int

fn C.LAPACKE_dgesvd(matrix_layout blas.MemoryLayout, jobu SVDJob, jobvt SVDJob, m int, n int, a &f64, lda int, s &f64, u &f64, ldu int, vt &f64, ldvt int, superb &f64) int

fn C.LAPACKE_dgetrf(matrix_layout blas.MemoryLayout, m int, n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dgetri(matrix_layout blas.MemoryLayout, n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dpotrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f64, lda int) int

fn C.LAPACKE_dgeev(matrix_layout blas.MemoryLayout, calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob, n int, a &f64, lda int, wr &f64, wi &f64, vl &f64, ldvl_ int, vr &f64, ldvr_ int) int

fn C.LAPACKE_dsyev(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a &f64, lda int, w &f64) int

fn C.LAPACKE_dgebal(matrix_layout blas.MemoryLayout, job BalanceJob, n int, a &f64, lda int, ilo int, ihi int, scale &f64) int

fn C.LAPACKE_dgehrd(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a &f64, lda int, tau &f64, work &f64, lwork int) int

// QR Factorization family
fn C.LAPACKE_sgeqrf(matrix_layout blas.MemoryLayout, m int, n int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_dgeqrf(matrix_layout blas.MemoryLayout, m int, n int, a &f64, lda int, tau &f64) int
fn C.LAPACKE_cgeqrf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zgeqrf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, tau voidptr) int

fn C.LAPACKE_sorgqr(matrix_layout blas.MemoryLayout, m int, n int, k int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_dorgqr(matrix_layout blas.MemoryLayout, m int, n int, k int, a &f64, lda int, tau &f64) int
fn C.LAPACKE_cungqr(matrix_layout blas.MemoryLayout, m int, n int, k int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zungqr(matrix_layout blas.MemoryLayout, m int, n int, k int, a voidptr, lda int, tau voidptr) int

fn C.LAPACKE_sormqr(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a &f32, lda int, tau &f32, c &f32, ldc int) int
fn C.LAPACKE_dormqr(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a &f64, lda int, tau &f64, c &f64, ldc int) int
fn C.LAPACKE_cunmqr(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a voidptr, lda int, tau voidptr, c voidptr, ldc int) int
fn C.LAPACKE_zunmqr(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a voidptr, lda int, tau voidptr, c voidptr, ldc int) int

// LQ Factorization family
fn C.LAPACKE_sgelqf(matrix_layout blas.MemoryLayout, m int, n int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_dgelqf(matrix_layout blas.MemoryLayout, m int, n int, a &f64, lda int, tau &f64) int
fn C.LAPACKE_cgelqf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zgelqf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, tau voidptr) int

fn C.LAPACKE_sorglq(matrix_layout blas.MemoryLayout, m int, n int, k int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_dorglq(matrix_layout blas.MemoryLayout, m int, n int, k int, a &f64, lda int, tau &f64) int
fn C.LAPACKE_cunglq(matrix_layout blas.MemoryLayout, m int, n int, k int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zunglq(matrix_layout blas.MemoryLayout, m int, n int, k int, a voidptr, lda int, tau voidptr) int

fn C.LAPACKE_sormlq(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a &f32, lda int, tau &f32, c &f32, ldc int) int
fn C.LAPACKE_dormlq(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a &f64, lda int, tau &f64, c &f64, ldc int) int
fn C.LAPACKE_cunmlq(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a voidptr, lda int, tau voidptr, c voidptr, ldc int) int
fn C.LAPACKE_zunmlq(matrix_layout blas.MemoryLayout, side blas.Side, trans blas.Transpose, m int, n int, k int, a voidptr, lda int, tau voidptr, c voidptr, ldc int) int

// Enhanced LU Factorization
fn C.LAPACKE_sgetrf(matrix_layout blas.MemoryLayout, m int, n int, a &f32, lda int, ipiv &int) int
fn C.LAPACKE_cgetrf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, ipiv &int) int
fn C.LAPACKE_zgetrf(matrix_layout blas.MemoryLayout, m int, n int, a voidptr, lda int, ipiv &int) int

fn C.LAPACKE_sgetri(matrix_layout blas.MemoryLayout, n int, a &f32, lda int, ipiv &int) int
fn C.LAPACKE_cgetri(matrix_layout blas.MemoryLayout, n int, a voidptr, lda int, ipiv &int) int
fn C.LAPACKE_zgetri(matrix_layout blas.MemoryLayout, n int, a voidptr, lda int, ipiv &int) int

fn C.LAPACKE_sgetrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, nrhs int, a &f32, lda int, ipiv &int, b &f32, ldb int) int
fn C.LAPACKE_dgetrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, nrhs int, a &f64, lda int, ipiv &int, b &f64, ldb int) int
fn C.LAPACKE_cgetrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, nrhs int, a voidptr, lda int, ipiv &int, b voidptr, ldb int) int
fn C.LAPACKE_zgetrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, nrhs int, a voidptr, lda int, ipiv &int, b voidptr, ldb int) int

fn C.LAPACKE_sgecon(matrix_layout blas.MemoryLayout, norm MatrixNorm, n int, a &f32, lda int, anorm f32, rcond &f32) int
fn C.LAPACKE_dgecon(matrix_layout blas.MemoryLayout, norm MatrixNorm, n int, a &f64, lda int, anorm f64, rcond &f64) int
fn C.LAPACKE_cgecon(matrix_layout blas.MemoryLayout, norm MatrixNorm, n int, a voidptr, lda int, anorm f32, rcond &f32) int
fn C.LAPACKE_zgecon(matrix_layout blas.MemoryLayout, norm MatrixNorm, n int, a voidptr, lda int, anorm f64, rcond &f64) int

// Cholesky Factorization
fn C.LAPACKE_spotrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f32, lda int) int
fn C.LAPACKE_cpotrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int) int
fn C.LAPACKE_zpotrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int) int

fn C.LAPACKE_spotri(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f32, lda int) int
fn C.LAPACKE_dpotri(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f64, lda int) int
fn C.LAPACKE_cpotri(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int) int
fn C.LAPACKE_zpotri(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int) int

fn C.LAPACKE_spotrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, nrhs int, a &f32, lda int, b &f32, ldb int) int
fn C.LAPACKE_dpotrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, nrhs int, a &f64, lda int, b &f64, ldb int) int
fn C.LAPACKE_cpotrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, nrhs int, a voidptr, lda int, b voidptr, ldb int) int
fn C.LAPACKE_zpotrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, nrhs int, a voidptr, lda int, b voidptr, ldb int) int

fn C.LAPACKE_spocon(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f32, lda int, anorm f32, rcond &f32) int
fn C.LAPACKE_dpocon(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a &f64, lda int, anorm f64, rcond &f64) int
fn C.LAPACKE_cpocon(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int, anorm f32, rcond &f32) int
fn C.LAPACKE_zpocon(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, a voidptr, lda int, anorm f64, rcond &f64) int

// Symmetric eigenvalue problems
fn C.LAPACKE_ssyev(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a &f32, lda int, w &f32) int
fn C.LAPACKE_cheev(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a voidptr, lda int, w &f32) int
fn C.LAPACKE_zheev(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a voidptr, lda int, w &f64) int

fn C.LAPACKE_ssyevd(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a &f32, lda int, w &f32) int
fn C.LAPACKE_dsyevd(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a &f64, lda int, w &f64) int
fn C.LAPACKE_cheevd(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a voidptr, lda int, w &f32) int
fn C.LAPACKE_zheevd(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, uplo blas.Uplo, n int, a voidptr, lda int, w &f64) int

fn C.LAPACKE_ssyevr(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, range byte, uplo blas.Uplo, n int, a &f32, lda int, vl f32, vu f32, il int, iu int, abstol f32, m &int, w &f32, z &f32, ldz int, isuppz &int) int
fn C.LAPACKE_dsyevr(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, range byte, uplo blas.Uplo, n int, a &f64, lda int, vl f64, vu f64, il int, iu int, abstol f64, m &int, w &f64, z &f64, ldz int, isuppz &int) int
fn C.LAPACKE_cheevr(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, range byte, uplo blas.Uplo, n int, a voidptr, lda int, vl f32, vu f32, il int, iu int, abstol f32, m &int, w &f32, z voidptr, ldz int, isuppz &int) int
fn C.LAPACKE_zheevr(matrix_layout blas.MemoryLayout, jobz EigenVectorsJob, range byte, uplo blas.Uplo, n int, a voidptr, lda int, vl f64, vu f64, il int, iu int, abstol f64, m &int, w &f64, z voidptr, ldz int, isuppz &int) int

// General eigenvalue problems
fn C.LAPACKE_sgeev(matrix_layout blas.MemoryLayout, calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob, n int, a &f32, lda int, wr &f32, wi &f32, vl &f32, ldvl int, vr &f32, ldvr int) int
fn C.LAPACKE_cgeev(matrix_layout blas.MemoryLayout, calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob, n int, a voidptr, lda int, w voidptr, vl voidptr, ldvl int, vr voidptr, ldvr int) int
fn C.LAPACKE_zgeev(matrix_layout blas.MemoryLayout, calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob, n int, a voidptr, lda int, w voidptr, vl voidptr, ldvl int, vr voidptr, ldvr int) int

// SVD - Singular Value Decomposition
fn C.LAPACKE_sgesvd(matrix_layout blas.MemoryLayout, jobu SVDJob, jobvt SVDJob, m int, n int, a &f32, lda int, s &f32, u &f32, ldu int, vt &f32, ldvt int, superb &f32) int
fn C.LAPACKE_cgesvd(matrix_layout blas.MemoryLayout, jobu SVDJob, jobvt SVDJob, m int, n int, a voidptr, lda int, s &f32, u voidptr, ldu int, vt voidptr, ldvt int, superb &f32) int
fn C.LAPACKE_zgesvd(matrix_layout blas.MemoryLayout, jobu SVDJob, jobvt SVDJob, m int, n int, a voidptr, lda int, s &f64, u voidptr, ldu int, vt voidptr, ldvt int, superb &f64) int

fn C.LAPACKE_sgesdd(matrix_layout blas.MemoryLayout, jobz SVDJob, m int, n int, a &f32, lda int, s &f32, u &f32, ldu int, vt &f32, ldvt int) int
fn C.LAPACKE_dgesdd(matrix_layout blas.MemoryLayout, jobz SVDJob, m int, n int, a &f64, lda int, s &f64, u &f64, ldu int, vt &f64, ldvt int) int
fn C.LAPACKE_cgesdd(matrix_layout blas.MemoryLayout, jobz SVDJob, m int, n int, a voidptr, lda int, s &f32, u voidptr, ldu int, vt voidptr, ldvt int) int
fn C.LAPACKE_zgesdd(matrix_layout blas.MemoryLayout, jobz SVDJob, m int, n int, a voidptr, lda int, s &f64, u voidptr, ldu int, vt voidptr, ldvt int) int

// Matrix balancing and reduction
fn C.LAPACKE_sgebal(matrix_layout blas.MemoryLayout, job BalanceJob, n int, a &f32, lda int, ilo &int, ihi &int, scale &f32) int
fn C.LAPACKE_cgebal(matrix_layout blas.MemoryLayout, job BalanceJob, n int, a voidptr, lda int, ilo &int, ihi &int, scale &f32) int
fn C.LAPACKE_zgebal(matrix_layout blas.MemoryLayout, job BalanceJob, n int, a voidptr, lda int, ilo &int, ihi &int, scale &f64) int

fn C.LAPACKE_sgebak(matrix_layout blas.MemoryLayout, job BalanceJob, side blas.Side, n int, ilo int, ihi int, scale &f32, m int, v &f32, ldv int) int
fn C.LAPACKE_dgebak(matrix_layout blas.MemoryLayout, job BalanceJob, side blas.Side, n int, ilo int, ihi int, scale &f64, m int, v &f64, ldv int) int
fn C.LAPACKE_cgebak(matrix_layout blas.MemoryLayout, job BalanceJob, side blas.Side, n int, ilo int, ihi int, scale &f32, m int, v voidptr, ldv int) int
fn C.LAPACKE_zgebak(matrix_layout blas.MemoryLayout, job BalanceJob, side blas.Side, n int, ilo int, ihi int, scale &f64, m int, v voidptr, ldv int) int

fn C.LAPACKE_sgehrd(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_cgehrd(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zgehrd(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a voidptr, lda int, tau voidptr) int

fn C.LAPACKE_sorghr(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a &f32, lda int, tau &f32) int
fn C.LAPACKE_dorghr(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a &f64, lda int, tau &f64) int
fn C.LAPACKE_cunghr(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a voidptr, lda int, tau voidptr) int
fn C.LAPACKE_zunghr(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a voidptr, lda int, tau voidptr) int

// Band matrix solvers
fn C.LAPACKE_sgbsv(matrix_layout blas.MemoryLayout, n int, kl int, ku int, nrhs int, ab &f32, ldab int, ipiv &int, b &f32, ldb int) int
fn C.LAPACKE_dgbsv(matrix_layout blas.MemoryLayout, n int, kl int, ku int, nrhs int, ab &f64, ldab int, ipiv &int, b &f64, ldb int) int
fn C.LAPACKE_cgbsv(matrix_layout blas.MemoryLayout, n int, kl int, ku int, nrhs int, ab voidptr, ldab int, ipiv &int, b voidptr, ldb int) int
fn C.LAPACKE_zgbsv(matrix_layout blas.MemoryLayout, n int, kl int, ku int, nrhs int, ab voidptr, ldab int, ipiv &int, b voidptr, ldb int) int

fn C.LAPACKE_sgbtrf(matrix_layout blas.MemoryLayout, m int, n int, kl int, ku int, ab &f32, ldab int, ipiv &int) int
fn C.LAPACKE_dgbtrf(matrix_layout blas.MemoryLayout, m int, n int, kl int, ku int, ab &f64, ldab int, ipiv &int) int
fn C.LAPACKE_cgbtrf(matrix_layout blas.MemoryLayout, m int, n int, kl int, ku int, ab voidptr, ldab int, ipiv &int) int
fn C.LAPACKE_zgbtrf(matrix_layout blas.MemoryLayout, m int, n int, kl int, ku int, ab voidptr, ldab int, ipiv &int) int

fn C.LAPACKE_sgbtrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, kl int, ku int, nrhs int, ab &f32, ldab int, ipiv &int, b &f32, ldb int) int
fn C.LAPACKE_dgbtrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, kl int, ku int, nrhs int, ab &f64, ldab int, ipiv &int, b &f64, ldb int) int
fn C.LAPACKE_cgbtrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, kl int, ku int, nrhs int, ab voidptr, ldab int, ipiv &int, b voidptr, ldb int) int
fn C.LAPACKE_zgbtrs(matrix_layout blas.MemoryLayout, trans blas.Transpose, n int, kl int, ku int, nrhs int, ab voidptr, ldab int, ipiv &int, b voidptr, ldb int) int

// Positive definite band systems
fn C.LAPACKE_spbsv(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab &f32, ldab int, b &f32, ldb int) int
fn C.LAPACKE_dpbsv(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab &f64, ldab int, b &f64, ldb int) int
fn C.LAPACKE_cpbsv(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab voidptr, ldab int, b voidptr, ldb int) int
fn C.LAPACKE_zpbsv(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab voidptr, ldab int, b voidptr, ldb int) int

fn C.LAPACKE_spbtrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, ab &f32, ldab int) int
fn C.LAPACKE_dpbtrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, ab &f64, ldab int) int
fn C.LAPACKE_cpbtrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, ab voidptr, ldab int) int
fn C.LAPACKE_zpbtrf(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, ab voidptr, ldab int) int

fn C.LAPACKE_spbtrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab &f32, ldab int, b &f32, ldb int) int
fn C.LAPACKE_dpbtrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab &f64, ldab int, b &f64, ldb int) int
fn C.LAPACKE_cpbtrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab voidptr, ldab int, b voidptr, ldb int) int
fn C.LAPACKE_zpbtrs(matrix_layout blas.MemoryLayout, uplo blas.Uplo, n int, kd int, nrhs int, ab voidptr, ldab int, b voidptr, ldb int) int

// Tridiagonal systems
fn C.LAPACKE_sgtsv(matrix_layout blas.MemoryLayout, n int, nrhs int, dl &f32, d &f32, du &f32, b &f32, ldb int) int
fn C.LAPACKE_dgtsv(matrix_layout blas.MemoryLayout, n int, nrhs int, dl &f64, d &f64, du &f64, b &f64, ldb int) int
fn C.LAPACKE_cgtsv(matrix_layout blas.MemoryLayout, n int, nrhs int, dl voidptr, d voidptr, du voidptr, b voidptr, ldb int) int
fn C.LAPACKE_zgtsv(matrix_layout blas.MemoryLayout, n int, nrhs int, dl voidptr, d voidptr, du voidptr, b voidptr, ldb int) int

// Additional matrix functions
fn C.LAPACKE_slansy(matrix_layout blas.MemoryLayout, norm MatrixNorm, uplo blas.Uplo, n int, a &f32, lda int) f32
fn C.LAPACKE_dlansy(matrix_layout blas.MemoryLayout, norm MatrixNorm, uplo blas.Uplo, n int, a &f64, lda int) f64
fn C.LAPACKE_clanhe(matrix_layout blas.MemoryLayout, norm MatrixNorm, uplo blas.Uplo, n int, a voidptr, lda int) f32
fn C.LAPACKE_zlanhe(matrix_layout blas.MemoryLayout, norm MatrixNorm, uplo blas.Uplo, n int, a voidptr, lda int) f64

fn C.LAPACKE_slange(matrix_layout blas.MemoryLayout, norm MatrixNorm, m int, n int, a &f32, lda int) f32
fn C.LAPACKE_dlange(matrix_layout blas.MemoryLayout, norm MatrixNorm, m int, n int, a &f64, lda int) f64
fn C.LAPACKE_clange(matrix_layout blas.MemoryLayout, norm MatrixNorm, m int, n int, a voidptr, lda int) f32
fn C.LAPACKE_zlange(matrix_layout blas.MemoryLayout, norm MatrixNorm, m int, n int, a voidptr, lda int) f64

// ========================================
// V WRAPPER FUNCTIONS
// ========================================

// dgesv - Direct wrapper for LAPACKE_dgesv (flat array interface)
@[inline]
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) int {
	unsafe {
		return C.LAPACKE_dgesv(.row_major, n, nrhs, &a[0], lda, &ipiv[0], &b[0], ldb)
	}
}

// gesv - Solves a general system of linear equations AX=B using LU factorization
// Returns 0 on success
@[inline]
pub fn gesv(mut a [][]f64, mut b [][]f64) ! {
	m := a.len
	n := a[0].len
	nrhs := b[0].len

	if m != n {
		return errors.error('Matrix a must be square', .efailed)
	}
	if b.len != n {
		return errors.error('Matrix b must have same number of rows as a', .efailed)
	}

	mut a_flat := []f64{len: m * n}
	mut b_flat := []f64{len: n * nrhs}
	mut ipiv := []int{len: n}

	// Copy data to flat arrays (row-major)
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}
	for i in 0 .. n {
		for j in 0 .. nrhs {
			b_flat[i * nrhs + j] = b[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgesv(.row_major, n, nrhs, &a_flat[0], n, &ipiv[0], &b_flat[0], nrhs)

		if info != 0 {
			return errors.error('LAPACK dgesv failed with info=${info}', .efailed)
		}
	}

	// Copy results back
	for i in 0 .. n {
		for j in 0 .. nrhs {
			b[i][j] = b_flat[i * nrhs + j]
		}
	}
}

// dgesvd - Direct wrapper for LAPACKE_dgesvd (flat array interface)
@[inline]
pub fn dgesvd(jobu SVDJob, jobvt SVDJob, m int, n int, mut a []f64, lda int, s []f64, mut u []f64, ldu int, mut vt []f64, ldvt int, superb []f64) int {
	unsafe {
		return C.LAPACKE_dgesvd(.row_major, jobu, jobvt, m, n, &a[0], lda, &s[0], &u[0], ldu, &vt[0], ldvt, &superb[0])
	}
}

// gesvd - Computes the singular value decomposition (SVD) of a general rectangular matrix
// A = U * S * V^T
@[inline]
pub fn gesvd(a [][]f64, jobu SVDJob, jobvt SVDJob) !([]f64, [][]f64, [][]f64) {
	m := a.len
	n := a[0].len
	min_mn := if m < n { m } else { n }

	mut a_flat := []f64{len: m * n}
	mut s := []f64{len: min_mn}
	mut u := []f64{len: m * m}
	mut vt := []f64{len: n * n}
	mut superb := []f64{len: min_mn - 1}

	// Copy input matrix
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgesvd(.row_major, jobu, jobvt, m, n, &a_flat[0], n, &s[0], &u[0], m, &vt[0], n, &superb[0])

		if info != 0 {
			return errors.error('LAPACK dgesvd failed with info=${info}', .efailed)
		}
	}

	// Convert back to 2D arrays
	mut u_mat := [][]f64{len: m, init: []f64{len: m}}
	mut vt_mat := [][]f64{len: n, init: []f64{len: n}}

	for i in 0 .. m {
		for j in 0 .. m {
			u_mat[i][j] = u[i * m + j]
		}
	}
	for i in 0 .. n {
		for j in 0 .. n {
			vt_mat[i][j] = vt[i * n + j]
		}
	}

	return s, u_mat, vt_mat
}

// dgetrf - Direct wrapper for LAPACKE_dgetrf (flat array interface)
@[inline]
pub fn dgetrf(m int, n int, mut a []f64, lda int, mut ipiv []int) int {
	unsafe {
		return C.LAPACKE_dgetrf(.row_major, m, n, &a[0], lda, &ipiv[0])
	}
}

// getrf - Computes LU factorization of a general matrix
@[inline]
pub fn getrf(mut a [][]f64) !([]int) {
	m := a.len
	n := a[0].len

	mut a_flat := []f64{len: m * n}
	mut ipiv := []int{len: if m < n { m } else { n }}

	// Copy matrix to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgetrf(.row_major, m, n, &a_flat[0], n, &ipiv[0])

		if info != 0 {
			return errors.error('LAPACK dgetrf failed with info=${info}', .efailed)
		}
	}

	// Copy result back
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}

	return ipiv
}

// dgetri - Direct wrapper for LAPACKE_dgetri (flat array interface)
@[inline]
pub fn dgetri(n int, mut a []f64, lda int, mut ipiv []int) int {
	unsafe {
		return C.LAPACKE_dgetri(.row_major, n, &a[0], lda, &ipiv[0])
	}
}

// getri - Computes the inverse of a matrix using LU factorization
@[inline]
pub fn getri(mut a [][]f64, mut ipiv []int) ! {
	n := a.len
	if a[0].len != n {
		return errors.error('Matrix must be square', .efailed)
	}
	if ipiv.len != n {
		return errors.error('ipiv array must have length n', .efailed)
	}

	mut a_flat := []f64{len: n * n}

	// Copy matrix to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgetri(.row_major, n, &a_flat[0], n, &ipiv[0])

		if info != 0 {
			return errors.error('LAPACK dgetri failed with info=${info}', .efailed)
		}
	}

	// Copy result back
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}
}

// potrf - Computes Cholesky factorization of a positive definite matrix
@[inline]
pub fn potrf(mut a [][]f64, uplo blas.Uplo) ! {
	n := a.len
	if a[0].len != n {
		return errors.error('Matrix must be square', .efailed)
	}

	mut a_flat := []f64{len: n * n}

	// Copy matrix to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dpotrf(.row_major, uplo, n, &a_flat[0], n)

		if info != 0 {
			return errors.error('LAPACK dpotrf failed with info=${info}', .efailed)
		}
	}

	// Copy result back
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}
}

// geev - Computes eigenvalues and eigenvectors of a general matrix
@[inline]
pub fn geev(a [][]f64, calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob) !([]f64, []f64, [][]f64, [][]f64) {
	n := a.len
	if a[0].len != n {
		return errors.error('Matrix must be square', .efailed)
	}

	mut a_flat := []f64{len: n * n}
	mut wr := []f64{len: n}
	mut wi := []f64{len: n}
	mut vl := []f64{len: n * n}
	mut vr := []f64{len: n * n}

	// Copy matrix to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgeev(.row_major, calc_vl, calc_vr, n, &a_flat[0], n, &wr[0], &wi[0], &vl[0], n, &vr[0], n)

		if info != 0 {
			return errors.error('LAPACK dgeev failed with info=${info}', .efailed)
		}
	}

	// Convert eigenvector arrays back to 2D
	mut vl_mat := [][]f64{len: n, init: []f64{len: n}}
	mut vr_mat := [][]f64{len: n, init: []f64{len: n}}

	for i in 0 .. n {
		for j in 0 .. n {
			vl_mat[i][j] = vl[i * n + j]
			vr_mat[i][j] = vr[i * n + j]
		}
	}

	return wr, wi, vl_mat, vr_mat
}

// syev - Computes eigenvalues and eigenvectors of a symmetric matrix
@[inline]
pub fn syev(mut a [][]f64, jobz EigenVectorsJob, uplo blas.Uplo) !([]f64) {
	n := a.len
	if a[0].len != n {
		return errors.error('Matrix must be square', .efailed)
	}

	mut a_flat := []f64{len: n * n}
	mut w := []f64{len: n}

	// Copy matrix to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dsyev(.row_major, jobz, uplo, n, &a_flat[0], n, &w[0])

		if info != 0 {
			return errors.error('LAPACK dsyev failed with info=${info}', .efailed)
		}
	}

	// Copy eigenvectors back if requested
	if jobz == .ev_compute {
		for i in 0 .. n {
			for j in 0 .. n {
				a[i][j] = a_flat[i * n + j]
			}
		}
	}

	return w
}

// geqrf - Computes QR factorization of a general matrix
@[inline]
pub fn geqrf(mut a [][]f64) !([]f64) {
	m := a.len
	n := a[0].len
	min_mn := if m < n { m } else { n }

	mut a_flat := []f64{len: m * n}
	mut tau := []f64{len: min_mn}

	// Copy matrix to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dgeqrf(.row_major, m, n, &a_flat[0], n, &tau[0])

		if info != 0 {
			return errors.error('LAPACK dgeqrf failed with info=${info}', .efailed)
		}
	}

	// Copy result back
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}

	return tau
}

// orgqr - Generates the orthogonal matrix Q from QR factorization
@[inline]
pub fn orgqr(mut a [][]f64, tau []f64) ! {
	m := a.len
	n := a[0].len
	k := tau.len

	mut a_flat := []f64{len: m * n}

	// Copy matrix to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	unsafe {
		info := C.LAPACKE_dorgqr(.row_major, m, n, k, &a_flat[0], n, &tau[0])

		if info != 0 {
			return errors.error('LAPACK dorgqr failed with info=${info}', .efailed)
		}
	}

	// Copy result back
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}
}
