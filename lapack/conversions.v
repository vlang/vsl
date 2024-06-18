module lapack

import vsl.lapack.lapack64

// Direct specifies the direction of the multiplication for the Householder matrix.
pub type Direct = lapack64.Direct

// Sort is the sorting order.
pub type Sort = lapack64.Sort

// StoreV indicates the storage direction of elementary reflectors.
pub type StoreV = lapack64.StoreV

// MatrixNorm represents the kind of matrix norm to compute.
pub type MatrixNorm = lapack64.MatrixNorm

// MatrixType represents the kind of matrix represented in the data.
pub type MatrixType = lapack64.MatrixType

// Pivot specifies the pivot type for plane rotations.
pub type Pivot = lapack64.Pivot

// ApplyOrtho specifies which orthogonal matrix is applied in Dormbr.
pub type ApplyOrtho = lapack64.ApplyOrtho

// GenOrtho specifies which orthogonal matrix is generated in Dorgbr.
pub type GenOrtho = lapack64.GenOrtho

// SVDJob specifies the singular vector computation type for SVD.
pub type SVDJob = lapack64.SVDJob

// GSVDJob specifies the singular vector computation type for Generalized SVD.
pub type GSVDJob = lapack64.GSVDJob

// EVComp specifies how eigenvectors are computed in Dsteqr.
pub type EVComp = lapack64.EVComp

// EVJob specifies whether eigenvectors are computed in Dsyev.
pub type EVJob = lapack64.EVJob

// LeftEVJob specifies whether left eigenvectors are computed in Dgeev.
pub type LeftEVJob = lapack64.LeftEVJob

// RightEVJob specifies whether right eigenvectors are computed in Dgeev.
pub type RightEVJob = lapack64.RightEVJob

// BalanceJob specifies matrix balancing operation.
pub type BalanceJob = lapack64.BalanceJob

// SchurJob specifies whether the Schur form is computed in Dhseqr.
pub type SchurJob = lapack64.SchurJob

// SchurComp specifies whether and how the Schur vectors are computed in Dhseqr.
pub type SchurComp = lapack64.SchurComp

// UpdateSchurComp specifies whether the matrix of Schur vectors is updated in Dtrexc.
pub type UpdateSchurComp = lapack64.UpdateSchurComp

// EVSide specifies what eigenvectors are computed in Dtrevc3.
pub type EVSide = lapack64.EVSide

// EVHowMany specifies which eigenvectors are computed in Dtrevc3 and how.
pub type EVHowMany = lapack64.EVHowMany

// MaximizeNormXJob specifies the heuristic method for computing a contribution to
// the reciprocal Dif-estimate in Dlatdf.
pub type MaximizeNormXJob = lapack64.MaximizeNormXJob

// OrthoComp specifies whether and how the orthogonal matrix is computed in Dgghrd.
pub type OrthoComp = lapack64.OrthoComp
