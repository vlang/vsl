#include <stddef.h>

#if (defined(__GNUC__) || defined(__clang__)) && !defined(__TINYC__) \
	&& (defined(__x86_64__) || defined(__i386__))
#include <immintrin.h>
#define VSL_HAS_AVX2_DISPATCH 1

static int vsl_blas_cpu_has_avx2(void) {
	__builtin_cpu_init();
	return __builtin_cpu_supports("avx2");
}

static int vsl_blas_cpu_has_avx2_fma(void) {
	__builtin_cpu_init();
	return __builtin_cpu_supports("avx2") && __builtin_cpu_supports("fma");
}

__attribute__((target("avx2")))
static float vsl_blas_sdot_avx2(int n, const float *x, const float *y) {
	__m256d sum0 = _mm256_setzero_pd();
	__m256d sum1 = _mm256_setzero_pd();
	__m256d sum2 = _mm256_setzero_pd();
	__m256d sum3 = _mm256_setzero_pd();
	int i = 0;
	for (; i + 16 <= n; i += 16) {
		__m256 products0 = _mm256_mul_ps(_mm256_loadu_ps(x + i), _mm256_loadu_ps(y + i));
		__m256 products1 = _mm256_mul_ps(_mm256_loadu_ps(x + i + 8),
			_mm256_loadu_ps(y + i + 8));
		sum0 = _mm256_add_pd(sum0, _mm256_cvtps_pd(_mm256_castps256_ps128(products0)));
		sum1 = _mm256_add_pd(sum1, _mm256_cvtps_pd(_mm256_extractf128_ps(products0, 1)));
		sum2 = _mm256_add_pd(sum2, _mm256_cvtps_pd(_mm256_castps256_ps128(products1)));
		sum3 = _mm256_add_pd(sum3, _mm256_cvtps_pd(_mm256_extractf128_ps(products1, 1)));
	}
	__m256d total = _mm256_add_pd(_mm256_add_pd(sum0, sum1), _mm256_add_pd(sum2, sum3));
	double lanes[4];
	_mm256_storeu_pd(lanes, total);
	double sum = (lanes[0] + lanes[1]) + (lanes[2] + lanes[3]);
	for (; i < n; ++i) {
		sum += (double)(x[i] * y[i]);
	}
	return (float)sum;
}

__attribute__((target("avx2,fma")))
static double vsl_blas_ddot_avx2(int n, const double *x, const double *y) {
	__m256d sum0 = _mm256_setzero_pd();
	__m256d sum1 = _mm256_setzero_pd();
	__m256d sum2 = _mm256_setzero_pd();
	__m256d sum3 = _mm256_setzero_pd();
	int i = 0;
	for (; i + 16 <= n; i += 16) {
		sum0 = _mm256_fmadd_pd(_mm256_loadu_pd(x + i), _mm256_loadu_pd(y + i), sum0);
		sum1 = _mm256_fmadd_pd(_mm256_loadu_pd(x + i + 4), _mm256_loadu_pd(y + i + 4),
			sum1);
		sum2 = _mm256_fmadd_pd(_mm256_loadu_pd(x + i + 8), _mm256_loadu_pd(y + i + 8),
			sum2);
		sum3 = _mm256_fmadd_pd(_mm256_loadu_pd(x + i + 12), _mm256_loadu_pd(y + i + 12),
			sum3);
	}
	__m256d total = _mm256_add_pd(_mm256_add_pd(sum0, sum1), _mm256_add_pd(sum2, sum3));
	double lanes[4];
	_mm256_storeu_pd(lanes, total);
	double sum = (lanes[0] + lanes[1]) + (lanes[2] + lanes[3]);
	for (; i < n; ++i) {
		sum += x[i] * y[i];
	}
	return sum;
}

__attribute__((target("avx2,fma")))
static void vsl_blas_daxpy_avx2(int n, double alpha, const double *x, double *y) {
	__m256d valpha = _mm256_set1_pd(alpha);
	int i = 0;
	for (; i + 16 <= n; i += 16) {
		_mm256_storeu_pd(y + i, _mm256_fmadd_pd(valpha, _mm256_loadu_pd(x + i),
			_mm256_loadu_pd(y + i)));
		_mm256_storeu_pd(y + i + 4, _mm256_fmadd_pd(valpha, _mm256_loadu_pd(x + i + 4),
			_mm256_loadu_pd(y + i + 4)));
		_mm256_storeu_pd(y + i + 8, _mm256_fmadd_pd(valpha, _mm256_loadu_pd(x + i + 8),
			_mm256_loadu_pd(y + i + 8)));
		_mm256_storeu_pd(y + i + 12, _mm256_fmadd_pd(valpha, _mm256_loadu_pd(x + i + 12),
			_mm256_loadu_pd(y + i + 12)));
	}
	for (; i < n; ++i) {
		y[i] = alpha * x[i] + y[i];
	}
}

__attribute__((target("avx2")))
static void vsl_blas_dscal_avx2(int n, double alpha, double *x) {
	__m256d valpha = _mm256_set1_pd(alpha);
	int i = 0;
	for (; i + 16 <= n; i += 16) {
		_mm256_storeu_pd(x + i, _mm256_mul_pd(valpha, _mm256_loadu_pd(x + i)));
		_mm256_storeu_pd(x + i + 4, _mm256_mul_pd(valpha, _mm256_loadu_pd(x + i + 4)));
		_mm256_storeu_pd(x + i + 8, _mm256_mul_pd(valpha, _mm256_loadu_pd(x + i + 8)));
		_mm256_storeu_pd(x + i + 12, _mm256_mul_pd(valpha, _mm256_loadu_pd(x + i + 12)));
	}
	for (; i < n; ++i) {
		x[i] *= alpha;
	}
}
#endif

float vsl_blas_sdot_dispatch(int n, const float *x, const float *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2()) {
		return vsl_blas_sdot_avx2(n, x, y);
	}
#endif
	double sum = 0.0;
	for (int i = 0; i < n; ++i) {
		sum += (double)(x[i] * y[i]);
	}
	return (float)sum;
}

double vsl_blas_ddot_dispatch(int n, const double *x, const double *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2_fma()) {
		return vsl_blas_ddot_avx2(n, x, y);
	}
#endif
	double sum = 0.0;
	for (int i = 0; i < n; ++i) {
		sum += x[i] * y[i];
	}
	return sum;
}

int vsl_blas_avx2_supported(void) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	return vsl_blas_cpu_has_avx2();
#else
	return 0;
#endif
}

int vsl_blas_avx2_fma_supported(void) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	return vsl_blas_cpu_has_avx2_fma();
#else
	return 0;
#endif
}

void vsl_blas_daxpy_dispatch(int n, double alpha, const double *x, double *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2_fma()) {
		vsl_blas_daxpy_avx2(n, alpha, x, y);
		return;
	}
#endif
	for (int i = 0; i < n; ++i) {
		y[i] = alpha * x[i] + y[i];
	}
}

void vsl_blas_dscal_dispatch(int n, double alpha, double *x) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2()) {
		vsl_blas_dscal_avx2(n, alpha, x);
		return;
	}
#endif
	for (int i = 0; i < n; ++i) {
		x[i] *= alpha;
	}
}
