module vlas

#flag linux -O2 -I/usr/local/include -I/usr/lib
#flag linux -L/usr/local/lib -L/usr/lib
#flag windows -O2
#flag windows -lgfortran
// Intel, M1 brew, and MacPorts
#flag darwin -I/usr/local/opt/openblas/include -I/opt/homebrew/opt/openblas/include -I/opt/local/opt/openblas/include
#flag darwin -L/usr/local/opt/openblas/lib -L/opt/homebrew/opt/openblas/lib -L/opt/local/opt/openblas/lib
#flag darwin -L/usr/local/opt/lapack/lib -L/opt/homebrew/opt/lapack/lib -L/opt/local/opt/lapack/lib
#flag -I@VMODROOT
#flag -lopenblas -llapacke

$if macos {
	#include <lapacke.h>
	#include <cblas.h>
}
