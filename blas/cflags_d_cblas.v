module blas

#flag linux -O2 -I/usr/local/include -I/usr/lib -I@VMODROOT
#flag linux -lopenblas -llapacke -L/usr/local/lib -L/usr/lib
#flag windows -O2
#flag windows -lopenblas -lgfortran
#flag darwin -I/usr/local/opt/openblas/include -I/usr/local/include -I/usr/lib -I/opt/homebrew/opt/openblas/include -I@VMODROOT
#flag darwin -lopenblas -llapacke -L/usr/local/opt/openblas/lib -L/usr/local/lib -L/usr/lib -L/opt/homebrew/opt/openblas/lib
