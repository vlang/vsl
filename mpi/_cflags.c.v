module mpi

#flag linux -I/usr/lib/x86_64-linux-gnu/openmpi/include -I/usr/include/x86_64-linux-gnu/mpi -pthread
#flag linux -pthread -L/usr/lib/x86_64-linux-gnu/openmpi/lib
#flag freebsd -I/usr/local/include
#flag freebsd -L/usr/local/opt/libevent/lib -L/usr/local/lib
#flag openbsd -I/usr/local/include
#flag openbsd -L/usr/local/opt/libevent/lib -L/usr/local/lib
// Intel, M1 brew, and MacPorts
#flag darwin -I/usr/local/include -I/opt/homebrew/include -I/opt/local/include
#flag darwin -L/usr/local/lib -L/opt/homebrew/lib -L/opt/local/lib
#flag darwin -L/usr/local/opt/libevent/lib -L/opt/homebrew/opt/libevent/lib -L/opt/local/opt/libevent/lib
#flag -I@VMODROOT
#flag -lmpi

#include <cmpi.h>
