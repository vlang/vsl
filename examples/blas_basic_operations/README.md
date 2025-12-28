# Example - blas_basic_operations 📘

This example demonstrates basic BLAS operations at all three levels:

- **Level 1**: Vector operations (dot product, norms, scaling, addition)
- **Level 2**: Matrix-vector operations (matrix-vector multiply, rank-1 update)
- **Level 3**: Matrix-matrix operations (matrix multiply, symmetric rank-k update)

## Instructions

1. Ensure you have the V compiler installed. You can download it from [here](https://vlang.io).
2. Ensure you have the VSL installed. You can do it following the [installation guide](https://github.com/vlang/vsl?tab=readme-ov-file#-installation)!
3. Navigate to this directory.
4. Run the example using the following command:

```sh
v run main.v
```

## What This Example Shows

### Level 1 BLAS
- `ddot`: Dot product of two vectors
- `dnrm2`: Euclidean norm of a vector
- `dasum`: Sum of absolute values
- `idamax`: Index of maximum absolute value
- `dscal`: Vector scaling
- `daxpy`: Vector addition (y = alpha*x + y)

### Level 2 BLAS
- `dgemv`: General matrix-vector multiplication
- `dger`: Rank-1 update (A += alpha*x*y^T)

### Level 3 BLAS
- `dgemm`: General matrix-matrix multiplication
- `dsyrk`: Symmetric rank-k update

## Backend Options

This example uses the **pure V BLAS backend** by default (zero dependencies).

To use the OpenBLAS C backend for comparison:

```sh
v -d vsl_blas_cblas run main.v
```

## Performance Notes

- Pure V backend provides excellent performance with zero dependencies
- C backend (`-d vsl_blas_cblas`) may offer slightly better performance for very large problems
- For most use cases, pure V backend is recommended for simplicity

## See Also

- [BLAS Module Documentation](../../blas/README.md)
- [BLAS Performance Benchmarks](../../benchmarks/README.md)
- [Pure V BLAS/LAPACK Release Notes](../../RELEASE_NOTES_PURE_V.md)

Enjoy exploring the capabilities of VSL BLAS! 😊

