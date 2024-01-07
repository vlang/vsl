module lapack

#flag linux -O2 -I/usr/local/include -I/usr/lib
#flag linux -L/usr/local/lib -L/usr/lib
#flag windows -O2
#flag windows -lgfortran
// Intel, M1 brew, and MacPorts
#flag darwin -L/usr/local/opt/lapack/lib -L/opt/homebrew/opt/lapack/lib -L/opt/local/opt/lapack/lib
#flag -I@VMODROOT
#flag -llapacke

$if macos {
	#include <lapacke.h>
}
