module h5

#flag linux -I@VMODROOT
#flag linux -pthread -lhdf5 -lhdf5_hl
#flag darwin -I@VMODROOT
#flag darwin -lhdf5 -lhdf5_hl
#flag freebsd -I/usr/local/include -I@VMODROOT
#flag freebsd -L/usr/local/lib
#flag openbsd -I/usr/local/include
#flag openbsd -L/usr/local/lib
#flag -lhdf5
#flag -lhdf5_hl

#include <hdf5.h>
#include <hdf5_hl.h>
