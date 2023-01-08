module vcl

$if dlnc {
#flag linux -I@VMODROOT
#flag linux -lOpenCL               
#flag windows -lOpenCL
#flag darwin -I@VMODROOT
#flag darwin -framework OpenCL

#include <vcl.h>
}else{

}
        
