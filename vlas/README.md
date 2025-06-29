# V Linear Algebra System

This package implements BLAS and LAPACKE functions. It provides different backends:

| Backend  | Description                                         | Status  | Compilation Flags     |
| -------- | --------------------------------------------------- | ------- | --------------------- |
| VLAS     | Pure V implementation                               | WIP     | `NONE`                |
| OpenBLAS | OpenBLAS optimized BLAS library. See [OpenBLAS     | Working | `-d vsl_vlas_cblas`   |
|          | Backend](#openblas-backend) for more information.  |         |                       |
| LAPACKE  | C interface to LAPACK linear algebra routines      | Working | `-d vsl_vlas_lapacke` |

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## OpenBLAS Backend

Use the flag `-d vsl_vlas_cblas` to use the OpenBLAS backend.

### Install dependencies

#### Debian/Ubuntu GNU Linux

`libopenblas-dev` is not needed when using the pure V backend.

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    libopenblas-dev
```

#### Arch Linux/Manjaro GNU Linux

The best way of installing OpenBlas is using
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

#### macOS

```sh
brew install openblas
```

## LAPACKE Backend

Use the flag `-d vsl_vlas_lapacke` to use the LAPACKE backend (enabled by default for now).

### Install dependencies

#### Debian/Ubuntu GNU Linux

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    liblapacke-dev
```

#### Arch Linux/Manjaro GNU Linux

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
