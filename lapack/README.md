# The V Linear Algebra Package

This package implements Linear Algebra routines in V.

| Backend | Description                                                                                                                                                       | Status | Compilation Flags       |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ----------------------- |
| BLAS    | Pure V implementation                                                                                                                                             | WIP    | `NONE`                  |
| LAPACKE | LAPACKE is a C interface to LAPACK. It is a standard part of the LAPACK distribution. Check the section [LAPACKE Backend](#lapacke-backend) for more information. | Stable | `-d vsl_lapack_lapacke` |

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## LAPACKE Backend

We provide a backend for the LAPACKE library. This backend is probably
the fastest one for all platforms
but it requires the installation of the LAPACKE library.

Use the compilation flag `-d vsl_lapack_lapacke` to use the LAPACKE backend
instead of the pure V implementation
and make sure that the LAPACKE library is installed in your system.

Check the section below for more information about installing the LAPACKE library.

<details>
<summary>Install dependencies</summary>

### Homebrew (macOS)

```sh
brew install lapack
```

### Debian/Ubuntu GNU Linux

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    liblapacke-dev
```

### Arch Linux/Manjaro GNU Linux

The best way of installing LAPACKE is using
[lapack-openblas](https://aur.archlinux.org/packages/lapack-openblas/).

```sh
yay -S lapack-openblas
```

or

```sh
git clone https://aur.archlinux.org/lapack-openblas.git /tmp/lapack-openblas
cd /tmp/lapack-openblas
makepkg -si
```

</details>
