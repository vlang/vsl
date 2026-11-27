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

__attribute__((target("avx2")))
static void vsl_blas_sgemv_t_avx2(int m, int n, int lda, float alpha, const float *a,
	const float *x, float beta, float *y) {
	int j = 0;
	for (; j + 8 <= n; j += 8) {
		__m256 sum = _mm256_setzero_ps();
		for (int i = 0; i < m; ++i) {
			__m256 row = _mm256_loadu_ps(a + (size_t)i * lda + j);
			__m256 xv = _mm256_set1_ps(x[i]);
			sum = _mm256_add_ps(sum, _mm256_mul_ps(row, xv));
		}
		float lanes[8];
		_mm256_storeu_ps(lanes, sum);
		for (int lane = 0; lane < 8; ++lane) {
			float product = alpha * lanes[lane];
			y[j + lane] = beta == 0 ? product : beta * y[j + lane] + product;
		}
	}
	for (; j < n; ++j) {
		float sum = 0.0f;
		for (int i = 0; i < m; ++i) {
			sum += a[(size_t)i * lda + j] * x[i];
		}
		float product = alpha * sum;
		y[j] = beta == 0 ? product : beta * y[j] + product;
	}
}

__attribute__((target("avx2,fma")))
static void vsl_blas_dgemv_t_avx2(int m, int n, int lda, double alpha, const double *a,
	const double *x, double beta, double *y) {
	int j = 0;
	for (; j + 4 <= n; j += 4) {
		__m256d sum = _mm256_setzero_pd();
		for (int i = 0; i < m; ++i) {
			__m256d row = _mm256_loadu_pd(a + (size_t)i * lda + j);
			__m256d xv = _mm256_set1_pd(x[i]);
			sum = _mm256_fmadd_pd(row, xv, sum);
		}
		double lanes[4];
		_mm256_storeu_pd(lanes, sum);
		for (int lane = 0; lane < 4; ++lane) {
			double product = alpha * lanes[lane];
			y[j + lane] = beta == 0 ? product : beta * y[j + lane] + product;
		}
	}
	for (; j < n; ++j) {
		double sum = 0.0;
		for (int i = 0; i < m; ++i) {
			sum += a[(size_t)i * lda + j] * x[i];
		}
		double product = alpha * sum;
		y[j] = beta == 0 ? product : beta * y[j] + product;
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

void vsl_blas_sgemv_n_dispatch(int m, int n, int lda, float alpha, const float *a,
	const float *x, float beta, float *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2()) {
		for (int i = 0; i < m; ++i) {
			float sum = vsl_blas_sdot_avx2(n, a + (size_t)i * lda, x);
			float product = alpha * sum;
			y[i] = beta == 0 ? product : beta * y[i] + product;
		}
		return;
	}
#endif
	for (int i = 0; i < m; ++i) {
		float sum = 0.0f;
		for (int j = 0; j < n; ++j) {
			sum += a[(size_t)i * lda + j] * x[j];
		}
		float product = alpha * sum;
		y[i] = beta == 0 ? product : beta * y[i] + product;
	}
}

void vsl_blas_dgemv_n_dispatch(int m, int n, int lda, double alpha, const double *a,
	const double *x, double beta, double *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (n >= 128 && vsl_blas_cpu_has_avx2_fma()) {
		for (int i = 0; i < m; ++i) {
			double sum = vsl_blas_ddot_avx2(n, a + (size_t)i * lda, x);
			double product = alpha * sum;
			y[i] = beta == 0 ? product : beta * y[i] + product;
		}
		return;
	}
#endif
	for (int i = 0; i < m; ++i) {
		double sum = 0.0;
		for (int j = 0; j < n; ++j) {
			sum += a[(size_t)i * lda + j] * x[j];
		}
		double product = alpha * sum;
		y[i] = beta == 0 ? product : beta * y[i] + product;
	}
}

void vsl_blas_sgemv_t_dispatch(int m, int n, int lda, float alpha, const float *a,
	const float *x, float beta, float *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (m >= 128 && vsl_blas_cpu_has_avx2()) {
		vsl_blas_sgemv_t_avx2(m, n, lda, alpha, a, x, beta, y);
		return;
	}
#endif
	for (int j = 0; j < n; ++j) {
		float sum = 0.0f;
		for (int i = 0; i < m; ++i) {
			sum += a[(size_t)i * lda + j] * x[i];
		}
		float product = alpha * sum;
		y[j] = beta == 0 ? product : beta * y[j] + product;
	}
}

void vsl_blas_dgemv_t_dispatch(int m, int n, int lda, double alpha, const double *a,
	const double *x, double beta, double *y) {
#if defined(VSL_HAS_AVX2_DISPATCH)
	if (m >= 128 && vsl_blas_cpu_has_avx2_fma()) {
		vsl_blas_dgemv_t_avx2(m, n, lda, alpha, a, x, beta, y);
		return;
	}
#endif
	for (int j = 0; j < n; ++j) {
		double sum = 0.0;
		for (int i = 0; i < m; ++i) {
			sum += a[(size_t)i * lda + j] * x[i];
		}
		double product = alpha * sum;
		y[j] = beta == 0 ? product : beta * y[j] + product;
	}
}
