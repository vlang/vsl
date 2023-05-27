# V Linear Algebra System

This package implements BLAS and LAPACKE functions. It provides different backends:

| Backend  | Description                                                                                                                                                        | Status  | Compilation Flags |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | ----------------- |
| VLAS     | Pure V implementation                                                                                                                                              | WIP     | `-d vlas`         |
| OpenBLAS | OpenBLAS is an optimized BLAS library based on <https://github.com/xianyi/OpenBLAS>. Check the section [OpenBLAS Backend](#openblas-backend) for more information. | Working | `-d cblas`        |
| LAPACKE  | LAPACKE is a C interface to the LAPACK linear algebra routines                                                                                                     | Working | `-d lapacke`      |

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## OpenBLAS Backend

Use the flag `-d cblas` to use the OpenBLAS backend.

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
[openblas-lapack](https://aur.archlinux.org/packages/openblas-lapack/).

```sh
yay -S openblas-lapack
```

or

```sh
git clone https://aur.archlinux.org/openblas-lapack.git /tmp/openblas-lapack
cd /tmp/openblas-lapack
makepkg -si
```

#### macOS

```sh
brew install openblas
```

## LAPACKE Backend

Use the flag `-d lapacke` to use the LAPACKE backend.

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
[openblas-lapack](https://aur.archlinux.org/packages/openblas-lapack/).

```sh
yay -S openblas-lapack
```

or

```sh
git clone https://aur.archlinux.org/openblas-lapack.git /tmp/openblas-lapack
cd /tmp/openblas-lapack
makepkg -si
```
