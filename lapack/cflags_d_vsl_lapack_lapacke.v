module lapack

#flag linux -O2 -I/usr/local/include -I/usr/lib -I/usr/include
#flag linux -L/usr/local/lib -L/usr/lib
#flag linux -llapacke
#flag windows -O2
#flag windows -lgfortran
// Intel, M1 brew, and MacPorts
#flag darwin -L/usr/local/opt/lapack/lib -L/opt/homebrew/opt/lapack/lib -L/opt/local/opt/lapack/lib
#flag -I@VMODROOT
#flag -llapacke
