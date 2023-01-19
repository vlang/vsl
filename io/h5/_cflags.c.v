module h5

#flag linux -I/usr/include/hdf5/serial/ -I/usr/local/include
#flag linux -L/usr/lib -L/usr/lib/x86_64-linux-gnu/hdf5/serial/ -L/usr/local/lib -pthread -lhdf5 -lhdf5_hl
#flag darwin -I/usr/local/include
#flag darwin -lhdf5 -lhdf5_hl -L/usr/local/lib
#flag -I@VMODROOT

#flag -lhdf5
#flag -lhdf5_hl

#include <hdf5.h>
#include <hdf5_hl.h>
