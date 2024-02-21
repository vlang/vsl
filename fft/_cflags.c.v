module fft

#flag linux -I/usr/local/include
#flag linux -L/usr/lib -L/usr/local/lib
#flag freebsd -I/usr/local/include
#flag freebsd -L/usr/local/lib
#flag openbsd -I/usr/local/include
#flag openbsd -L/usr/local/lib
// Intel, M1 brew, and MacPorts
#flag darwin -I/usr/local/include -I/opt/homebrew/include -L/opt/local/lib
#flag darwin -L/usr/local/lib -L/opt/homebrew/lib -L/opt/local/lib
#flag -I@VMODROOT

#flag @VMODROOT/pocket-fft/f32.o
#flag @VMODROOT/pocket-fft/f64.o
#flag -lm

#include <pocket-fft/pocketfft_f32.h>
#include <pocket-fft/pocketfft_f64.h>
