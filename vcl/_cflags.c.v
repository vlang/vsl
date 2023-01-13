module vcl

$if shared_mode ? {
} $else {
	#flag linux -I@VMODROOT
	#flag linux -lOpenCL
	#flag windows -lOpenCL
	#flag darwin -I@VMODROOT
	#flag darwin -framework OpenCL
	#include <vcl.h>
}


