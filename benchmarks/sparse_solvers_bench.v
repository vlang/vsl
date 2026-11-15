module main

import math
import os
import time
import vsl.la

const dense_max_size = 2048
const dense_work_target = 3_000_000
const sparse_work_target = 3_000_000
const timed_samples = 5

fn cpu_model() string {
	cpuinfo := os.read_file('/proc/cpuinfo') or { return 'unavailable; record externally' }
	for line in cpuinfo.split_into_lines() {
		if line.starts_with('model name') {
			parts := line.split(':')
			if parts.len > 1 {
				return parts[1].trim_space()
			}
		}
	}
	return 'unavailable; record externally'
}

fn max_abs_difference(left []f64, right []f64) f64 {
	mut result := 0.0
	for i in 0 .. left.len {
		result = math.max(result, math.abs(left[i] - right[i]))
	}
	return result
}

fn main() {
	println('# cpu=${cpu_model()}, threads=1, matrix=1D Laplacian, value=f64')
	println('# payload bytes exclude V array headers, allocator overhead, and workspaces')
	println('n,nnz,iterations,samples,csr_payload_bytes,dense_payload_bytes,csr_us,dense_us,dense_over_csr,csr_checksum,dense_checksum')
	for n in [256, 512, 1024, 2048, 4096, 8192, 16384] {
		mut triplet := la.Triplet.new[f64](n, n, 3 * n)
		for row in 0 .. n {
			if row > 0 {
				triplet.put(row, row - 1, -1.0) or { panic(err) }
			}
			triplet.put(row, row, 2.0) or { panic(err) }
			if row + 1 < n {
				triplet.put(row, row + 1, -1.0) or { panic(err) }
			}
		}
		matrix := triplet.to_csr() or { panic(err) }
		mut vector := []f64{len: n}
		for i in 0 .. n {
			vector[i] = f64(i % 13) / 13.0
		}

		mut iterations := dense_work_target / (n * n)
		if n > dense_max_size {
			iterations = sparse_work_target / matrix.nnz()
		}
		if iterations < 3 {
			iterations = 3
		}
		csr_payload_bytes := u64(matrix.nnz()) * (u64(sizeof(f64)) + u64(sizeof(int))) +
			u64(n + 1) * u64(sizeof(int))
		dense_payload_bytes := u64(n) * u64(n) * u64(sizeof(f64))

		if n <= dense_max_size {
			dense := matrix.to_dense()
			sparse_reference := matrix.matvec(vector) or { panic(err) }
			dense_reference := la.matrix_vector_mul(1.0, dense, vector)
			if max_abs_difference(sparse_reference, dense_reference) > 1e-12 {
				panic('CSR and dense matvec differ at n=${n}')
			}
			for _ in 0 .. 3 {
				matrix.matvec(vector) or { panic(err) }
				la.matrix_vector_mul(1.0, dense, vector)
			}
			mut csr_checksum := 0.0
			mut csr_ns := i64(0)
			for _ in 0 .. timed_samples {
				started := time.sys_mono_now()
				for _ in 0 .. iterations {
					result := matrix.matvec(vector) or { panic(err) }
					csr_checksum += result[n - 1]
				}
				csr_ns += time.sys_mono_now() - started
			}
			mut dense_checksum := 0.0
			mut dense_ns := i64(0)
			for _ in 0 .. timed_samples {
				started := time.sys_mono_now()
				for _ in 0 .. iterations {
					result := la.matrix_vector_mul(1.0, dense, vector)
					dense_checksum += result[n - 1]
				}
				dense_ns += time.sys_mono_now() - started
			}
			total_calls := iterations * timed_samples
			csr_us := f64(csr_ns) / f64(total_calls) / 1e3
			dense_us := f64(dense_ns) / f64(total_calls) / 1e3
			ratio := if csr_us > 0.0 { dense_us / csr_us } else { 0.0 }
			println('${n},${matrix.nnz()},${iterations},${timed_samples},${csr_payload_bytes},${dense_payload_bytes},${csr_us:.3f},${dense_us:.3f},${ratio:.2f},${csr_checksum:.6f},${dense_checksum:.6f}')
		} else {
			mut csr_checksum := 0.0
			for _ in 0 .. 3 {
				matrix.matvec(vector) or { panic(err) }
			}
			mut csr_ns := i64(0)
			for _ in 0 .. timed_samples {
				started := time.sys_mono_now()
				for _ in 0 .. iterations {
					result := matrix.matvec(vector) or { panic(err) }
					csr_checksum += result[n - 1]
				}
				csr_ns += time.sys_mono_now() - started
			}
			total_calls := iterations * timed_samples
			csr_us := f64(csr_ns) / f64(total_calls) / 1e3
			println('${n},${matrix.nnz()},${iterations},${timed_samples},${csr_payload_bytes},NA,${csr_us:.3f},NA,NA,${csr_checksum:.6f},NA')
		}
	}
}
