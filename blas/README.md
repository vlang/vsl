# The V Basic Linear Algebra System

This package implements Basic Linear Algebra System (BLAS) routines in V.

| Backend  | Description                                                                                                                                                        | Status | Compilation Flags   |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ | ------------------- |
| BLAS     | Pure V implementation                                                                                                                                              | Stable | `NONE`              |
| OpenBLAS | OpenBLAS is an optimized BLAS library based on <https://github.com/xianyi/OpenBLAS>. Check the section [OpenBLAS Backend](#openblas-backend) for more information. | Stable | `-d vsl_blas_cblas` |

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## OpenBLAS Backend

We provide a backend for the OpenBLAS library. This backend is probably
the fastest one for all platforms
but it requires the installation of the OpenBLAS library.

Use the compilation flag `-d vsl_blas_cblas` to use the OpenBLAS backend
instead of the pure V implementation
and make sure that the OpenBLAS library is installed in your system.

Check the section below for more information about installing the OpenBLAS library.

<details>
<summary>Install dependencies</summary>

### Homebrew (macOS)

```sh
brew install openblas
```

### Debian/Ubuntu GNU Linux

`libopenblas-dev` is not needed when using the pure V backend.

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    libopenblas-dev
```

### Arch Linux/Manjaro GNU Linux

The best way of installing OpenBLAS is using
[blas-openblas](https://archlinux.org/packages/extra/x86_64/blas-openblas/).

```sh
sudo pacman -S blas-openblas
```

</details>
