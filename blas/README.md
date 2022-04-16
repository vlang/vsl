# Basic Linear Algebra System

This package implements BLAS functions. It provides two different backends:

- One using Open BLAS when using flag `-d cblas`.
  [Check also OpenBLAS](https://github.com/xianyi/OpenBLAS).
- One using a pure V implementation called VLAS, *by default*.
  This implementation can be found on `vsl.blas.vlas`.

Therefore, its routines are a little more
_lower level_ than the ones in the package `vsl.la`.

## Usage Example

```v
module main

import vsl.blas
import vsl.la

// matrix_matrix_mul returns the matrix multiplication (scaled)
//
//  c := alpha⋅a⋅b    ⇒    cij := alpha * aik * bkj
//
pub fn matrix_matrix_mul(mut c la.Matrix<f64>, alpha f64, a la.Matrix<f64>, b la.Matrix<f64>) {
	if c.m < 6 && c.n < 6 && a.n < 30 {
		for i := 0; i < c.m; i++ {
			for j := 0; j < c.n; j++ {
				c.set(i, j, 0.0)
				for k := 0; k < a.n; k++ {
					c.add(i, j, alpha * a.get(i, k) * b.get(k, j))
				}
			}
		}
		return
	}
	blas.dgemm(false, false, a.m, b.n, a.n, alpha, a.data, a.m, b.data, b.m, 0.0, mut
		c.data, c.m)
}
```

## Install dependencies

**Debian/Ubuntu GNU Linux**

`libopenblas-dev` is not needed when using the pure V backend.

```sh
$ sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    liblapacke-dev \
    libopenblas-dev \
    libssl-dev \
```

**Arch Linux/Manjaro GNU Linux**

```sh
$ sudo pacman -S openssl
```

The best way of installing OpenBlas/LAPACK is using
[openblas-lapack](https://aur.archlinux.org/packages/openblas-lapack/).

```sh
$ yay -S openblas-lapack
```

_or_

```sh
$ git clone https://aur.archlinux.org/openblas-lapack.git /tmp/openblas-lapack
$ cd /tmp/openblas-lapack
$ makepkg -si
```
