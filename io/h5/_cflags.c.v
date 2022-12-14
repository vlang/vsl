module h5

#flag linux -I/usr/local/include
#flag linux -pthread -lhdf5 -lhdf5_hl
#flag darwin
#flag darwin -lhdf5 -lhdf5_hl
#flag freebsd -I/usr/local/include
#flag freebsd -L/usr/local/lib
#flag openbsd -I/usr/local/include
#flag openbsd -L/usr/local/lib
#flag -lhdf5
#flag -lhdf5_hl

#include <hdf5.h>
#include <hdf5_hl.h>
