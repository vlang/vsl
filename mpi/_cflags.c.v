module mpi

#flag linux -I/usr/lib/x86_64-linux-gnu/openmpi/include -I/usr/include/x86_64-linux-gnu/mpi -pthread
#flag linux -pthread -L/usr/lib/x86_64-linux-gnu/openmpi/lib -lmpi
#flag darwin -I/usr/local/Cellar/open-mpi/4.1.5/include -I/usr/local/include
#flag darwin -L/usr/local/opt/libevent/lib -L/usr/local/Cellar/open-mpi/4.1.5/lib -L/usr/local/lib -lmpi
#flag freebsd -I/usr/local/Cellar/open-mpi/4.1.5/include -I/usr/local/include
#flag freebsd -L/usr/local/opt/libevent/lib -L/usr/local/Cellar/open-mpi/4.1.5/lib -L/usr/local/lib -lmpi
#flag openbsd -I/usr/local/Cellar/open-mpi/4.1.5/include -I/usr/local/include
#flag openbsd -L/usr/local/opt/libevent/lib -L/usr/local/Cellar/open-mpi/4.1.5/lib -L/usr/local/lib -lmpi
#flag -I@VMODROOT

#include <cmpi.h>
