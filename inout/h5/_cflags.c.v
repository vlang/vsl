module h5

#flag linux -I/usr/include/hdf5/serial/ -I/usr/local/include
#flag linux -L/usr/lib -L/usr/lib/x86_64-linux-gnu/hdf5/serial/ -L/usr/local/lib -pthread
#flag freebsd -I/usr/local/include
#flag freebsd -L/usr/local/lib
#flag openbsd -I/usr/local/include
#flag openbsd -L/usr/local/lib
// Intel, M1 brew, and MacPorts
#flag darwin -I/usr/local/include -I/opt/homebrew/include -L/opt/local/lib
#flag darwin -L/usr/local/lib -L/opt/homebrew/lib -L/opt/local/lib
#flag -I@VMODROOT
#flag -lhdf5 -lhdf5_hl

#include <hdf5.h>
#include <hdf5_hl.h>
