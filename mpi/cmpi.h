#ifndef V_MPI_H
#define V_MPI_H

#include "mpi.h"

MPI_Comm World = MPI_COMM_WORLD;
MPI_Op OpSum = MPI_SUM;
MPI_Op OpMin = MPI_MIN;
MPI_Op OpMax = MPI_MAX;
MPI_Datatype TyLong = MPI_LONG;
MPI_Datatype TyDouble = MPI_DOUBLE;
MPI_Datatype TyComplex = MPI_DOUBLE_COMPLEX;
MPI_Status *StIgnore = MPI_STATUS_IGNORE;

#define DOUBLE_COMPLEX double complex

#endif
