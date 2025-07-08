module lapack64

// Direct specifies the direction of the multiplication for the Householder matrix.
pub enum Direct as u8 {
	// Reflectors are right-multiplied, H_0 * H_1 * ... * H_{k-1}.
	forward = u8(`F`)
	// Reflectors are left-multiplied, H_{k-1} * ... * H_1 * H_0.
	backward = u8(`B`)
}

// Sort is the sorting order.
pub enum Sort as u8 {
	sort_increasing = u8(`I`)
	sort_decreasing = u8(`D`)
}

// StoreV indicates the storage direction of elementary reflectors.
pub enum StoreV as u8 {
	// Reflector stored in a column of the matrix.
	column_wise = u8(`C`)
	// Reflector stored in a row of the matrix.
	row_wise = u8(`R`)
}

// MatrixNorm represents the kind of matrix norm to compute.
pub enum MatrixNorm as u8 {
	// max(abs(A(i,j)))
	max_abs = u8(`M`)
	// Maximum absolute column sum (one norm)
	max_column_sum = u8(`O`)
	// Maximum absolute row sum (infinity norm)
	max_row_sum = u8(`I`)
	// Frobenius norm (sqrt of sum of squares)
	frobenius = u8(`F`)
}

// MatrixType represents the kind of matrix represented in the data.
pub enum MatrixType as u8 {
	// A general dense matrix.
	general = u8(`G`)
	// An upper triangular matrix.
	upper_tri = u8(`U`)
	// A lower triangular matrix.
	lower_tri = u8(`L`)
}

// Pivot specifies the pivot type for plane rotations.
pub enum Pivot as u8 {
	variable = u8(`V`)
	top      = u8(`T`)
	bottom   = u8(`B`)
}

// ApplyOrtho specifies which orthogonal matrix is applied in Dormbr.
pub enum ApplyOrtho as u8 {
	// Apply P or Pᵀ.
	apply_p = u8(`P`)
	// Apply Q or Qᵀ.
	apply_q = u8(`Q`)
}

// GenOrtho specifies which orthogonal matrix is generated in Dorgbr.
pub enum GenOrtho as u8 {
	// Generate Pᵀ.
	generate_pt = u8(`P`)
	// Generate Q.
	generate_q = u8(`Q`)
}

// SVDJob specifies the singular vector computation type for SingularValueDecomposition.
pub enum SVDJob as u8 {
	// Compute all columns of the orthogonal matrix U or V.
	svd_all = u8(`A`)
	// Compute the singular vectors and store them in the orthogonal matrix U or V.
	svd_store = u8(`S`)
	// Compute the singular vectors and overwrite them on the input matrix A.
	svd_overwrite = u8(`O`)
	// Do not compute singular vectors.
	svd_none = u8(`N`)
}

// GSVDJob specifies the singular vector computation type for Generalized SingularValueDecomposition.
pub enum GSVDJob as u8 {
	// Compute orthogonal matrix U.
	gsvd_u = u8(`U`)
	// Compute orthogonal matrix V.
	gsvd_v = u8(`V`)
	// Compute orthogonal matrix Q.
	gsvd_q = u8(`Q`)
	// Use unit-initialized matrix.
	gsvd_unit = u8(`I`)
	// Do not compute orthogonal matrix.
	gsvd_none = u8(`N`)
}

// EigenVectorsComp specifies how eigenvectors are computed in Dsteqr.
pub enum EigenVectorsComp as u8 {
	// Compute eigenvectors of the original symmetric matrix.
	ev_orig = u8(`V`)
	// Compute eigenvectors of the tridiagonal matrix.
	ev_tridiag = u8(`I`)
	// Do not compute eigenvectors.
	ev_comp_none = u8(`N`)
}

// EigenVectorsJob specifies whether eigenvectors are computed in Dsyev.
pub enum EigenVectorsJob as u8 {
	// Compute eigenvectors.
	ev_compute = u8(`V`)
	// Do not compute eigenvectors.
	ev_none = u8(`N`)
}

// LeftEigenVectorsJob specifies whether left eigenvectors are computed in Dgeev.
pub enum LeftEigenVectorsJob as u8 {
	// Compute left eigenvectors.
	left_ev_compute = u8(`V`)
	// Do not compute left eigenvectors.
	left_ev_none = u8(`N`)
}

// RightEigenVectorsJob specifies whether right eigenvectors are computed in Dgeev.
pub enum RightEigenVectorsJob as u8 {
	// Compute right eigenvectors.
	right_ev_compute = u8(`V`)
	// Do not compute right eigenvectors.
	right_ev_none = u8(`N`)
}

// BalanceJob specifies matrix balancing operation.
pub enum BalanceJob as u8 {
	permute       = u8(`P`)
	scale         = u8(`S`)
	permute_scale = u8(`B`)
	balance_none  = u8(`N`)
}

// SchurJob specifies whether the Schur form is computed in Dhseqr.
pub enum SchurJob as u8 {
	eigenvalues_only      = u8(`E`)
	eigenvalues_and_schur = u8(`S`)
}

// SchurComp specifies whether and how the Schur vectors are computed in Dhseqr.
pub enum SchurComp as u8 {
	// Compute Schur vectors of the original matrix.
	schur_orig = u8(`V`)
	// Compute Schur vectors of the upper Hessenberg matrix.
	schur_hess = u8(`I`)
	// Do not compute Schur vectors.
	schur_none = u8(`N`)
}

// UpdateSchurComp specifies whether the matrix of Schur vectors is updated in Dtrexc.
pub enum UpdateSchurComp as u8 {
	// Update the matrix of Schur vectors.
	update_schur = u8(`V`)
	// Do not update the matrix of Schur vectors.
	update_schur_none = u8(`N`)
}

// EigenVectorsSide specifies what eigenvectors are computed in Dtrevc3.
pub enum EigenVectorsSide as u8 {
	// Compute only right eigenvectors.
	ev_right = u8(`R`)
	// Compute only left eigenvectors.
	ev_left = u8(`L`)
	// Compute both right and left eigenvectors.
	ev_both = u8(`B`)
}

// EigenVectorsHowMany specifies which eigenvectors are computed in Dtrevc3 and how.
pub enum EigenVectorsHowMany as u8 {
	// Compute all right and/or left eigenvectors.
	ev_all = u8(`A`)
	// Compute all right and/or left eigenvectors multiplied by an input matrix.
	ev_all_mul_q = u8(`B`)
	// Compute selected right and/or left eigenvectors.
	ev_selected = u8(`S`)
}

// MaximizeNormXJob specifies the heuristic method for computing a contribution to
// the reciprocal Dif-estimate in Dlatdf.
pub enum MaximizeNormXJob as u8 {
	// Solve Z*x=h-f where h is a vector of ±1.
	local_look_ahead = 0
	// Compute an approximate null-vector e of Z, normalize e and solve Z*x=±e-f.
	normalized_null_vector = 2
}

// OrthoComp specifies whether and how the orthogonal matrix is computed in Dgghrd.
pub enum OrthoComp as u8 {
	// Do not compute the orthogonal matrix.
	ortho_none = u8(`N`)
	// The orthogonal matrix is formed explicitly and returned in the argument.
	ortho_explicit = u8(`I`)
	// The orthogonal matrix is post-multiplied into the matrix stored in the argument on entry.
	ortho_postmul = u8(`V`)
}
