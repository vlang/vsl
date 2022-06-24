module mpi

#flag linux -I/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi -I/usr/lib/x86_64-linux-gnu/openmpi/include -pthread -I@VMODROOT
#flag linux -pthread -L/usr/lib/x86_64-linux-gnu/openmpi/lib -lmpi
#flag darwin -I/usr/local/Cellar/open-mpi/4.0.1_2/include -I@VMODROOT
#flag darwin -L/usr/local/opt/libevent/lib -L/usr/local/Cellar/open-mpi/4.0.1_2/lib -lmpi
#flag freebasd -I/usr/local/include -I@VMODROOT
#flag freebasd -L/usr/local/lib -lmpi

#include <cmpi.h>
