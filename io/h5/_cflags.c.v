module h5

#flag linux /usr/include/hdf5/serial/ -I/usr/local/include -I@VMODROOT
#flag linux -L/usr/lib -L/usr/lib/x86_64-linux-gnu/hdf5/serial/ -L/usr/local/lib -pthread -lhdf5 -lhdf5_hl
#flag darwin -I/usr/local/include -I@VMODROOT
#flag darwin -lhdf5 -lhdf5_hl
#flag freebsd -I/usr/local/include -I@VMODROOT
#flag freebsd -L/usr/local/lib
#flag openbsd -I/usr/local/include -I@VMODROOT
#flag openbsd -L/usr/local/lib

#flag -lhdf5
#flag -lhdf5_hl

#include <hdf5.h>
#include <hdf5_hl.h>
