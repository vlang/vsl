// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module blas

#flag linux -O2 -I/usr/local/include -I@VROOT/blas -I./blas
#flag linux -lopenblas -llapacke -L/usr/lib
#flag windows -O2
#flag windows -lopenblas -lgfortran
#flag darwin -I/usr/local/opt/openblas/include
#flag darwin -lopenblas -L/usr/local/opt/openblas/lib
