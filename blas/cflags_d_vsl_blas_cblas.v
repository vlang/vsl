module blas

#flag linux -O2 -I/usr/local/include -I/usr/lib
#flag linux -L/usr/local/lib -L/usr/lib
#flag windows -O2
#flag windows -lgfortran
// Intel, M1 brew, and MacPorts
#flag darwin -I/usr/local/opt/openblas/include -I/opt/homebrew/opt/openblas/include -I/opt/local/opt/openblas/include
#flag darwin -L/usr/local/opt/openblas/lib -L/opt/homebrew/opt/openblas/lib -L/opt/local/opt/openblas/lib
#flag -I@VMODROOT
#flag -lopenblas

$if macos {
	#include <cblas.h>
}
