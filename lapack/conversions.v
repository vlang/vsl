module lapack

import vsl.lapack.lapack64

// ========================================================================
// ENUM DEFINITIONS
// ========================================================================
// These are explicit enum definitions replacing type aliases.
// V's enum type aliases don't work as expected - they're treated as distinct types.

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

// ========================================================================
// ENUM CONVERSION FUNCTIONS
// ========================================================================
// These functions provide explicit conversion between VSL enum types and
// the underlying lapack64 enum types. This is necessary because V's enum
// type aliases don't work as expected - they're treated as distinct types.

// Convert VSL Direct to lapack64.Direct
pub fn to_lapack64_direct(direct Direct) lapack64.Direct {
	return match direct {
		.forward { lapack64.Direct.forward }
		.backward { lapack64.Direct.backward }
	}
}

// Convert lapack64.Direct to VSL Direct
pub fn from_lapack64_direct(direct lapack64.Direct) Direct {
	return match direct {
		.forward { Direct.forward }
		.backward { Direct.backward }
	}
}

// Convert VSL Sort to lapack64.Sort
pub fn to_lapack64_sort(sort Sort) lapack64.Sort {
	return match sort {
		.sort_increasing { lapack64.Sort.sort_increasing }
		.sort_decreasing { lapack64.Sort.sort_decreasing }
	}
}

// Convert lapack64.Sort to VSL Sort
pub fn from_lapack64_sort(sort lapack64.Sort) Sort {
	return match sort {
		.sort_increasing { Sort.sort_increasing }
		.sort_decreasing { Sort.sort_decreasing }
	}
}

// Convert VSL StoreV to lapack64.StoreV
pub fn to_lapack64_storev(storev StoreV) lapack64.StoreV {
	return match storev {
		.column_wise { lapack64.StoreV.column_wise }
		.row_wise { lapack64.StoreV.row_wise }
	}
}

// Convert lapack64.StoreV to VSL StoreV
pub fn from_lapack64_storev(storev lapack64.StoreV) StoreV {
	return match storev {
		.column_wise { StoreV.column_wise }
		.row_wise { StoreV.row_wise }
	}
}

// Convert VSL MatrixNorm to lapack64.MatrixNorm
pub fn to_lapack64_matrix_norm(norm MatrixNorm) lapack64.MatrixNorm {
	return match norm {
		.max_abs { lapack64.MatrixNorm.max_abs }
		.max_column_sum { lapack64.MatrixNorm.max_column_sum }
		.max_row_sum { lapack64.MatrixNorm.max_row_sum }
		.frobenius { lapack64.MatrixNorm.frobenius }
	}
}

// Convert lapack64.MatrixNorm to VSL MatrixNorm
pub fn from_lapack64_matrix_norm(norm lapack64.MatrixNorm) MatrixNorm {
	return match norm {
		.max_abs { MatrixNorm.max_abs }
		.max_column_sum { MatrixNorm.max_column_sum }
		.max_row_sum { MatrixNorm.max_row_sum }
		.frobenius { MatrixNorm.frobenius }
	}
}

// Convert VSL MatrixType to lapack64.MatrixType
pub fn to_lapack64_matrix_type(mtype MatrixType) lapack64.MatrixType {
	return match mtype {
		.general { lapack64.MatrixType.general }
		.upper_tri { lapack64.MatrixType.upper_tri }
		.lower_tri { lapack64.MatrixType.lower_tri }
	}
}

// Convert lapack64.MatrixType to VSL MatrixType
pub fn from_lapack64_matrix_type(mtype lapack64.MatrixType) MatrixType {
	return match mtype {
		.general { MatrixType.general }
		.upper_tri { MatrixType.upper_tri }
		.lower_tri { MatrixType.lower_tri }
	}
}

// Convert VSL Pivot to lapack64.Pivot
pub fn to_lapack64_pivot(pivot Pivot) lapack64.Pivot {
	return match pivot {
		.variable { lapack64.Pivot.variable }
		.top { lapack64.Pivot.top }
		.bottom { lapack64.Pivot.bottom }
	}
}

// Convert lapack64.Pivot to VSL Pivot
pub fn from_lapack64_pivot(pivot lapack64.Pivot) Pivot {
	return match pivot {
		.variable { Pivot.variable }
		.top { Pivot.top }
		.bottom { Pivot.bottom }
	}
}

// Convert VSL ApplyOrtho to lapack64.ApplyOrtho
pub fn to_lapack64_apply_ortho(apply ApplyOrtho) lapack64.ApplyOrtho {
	return match apply {
		.apply_p { lapack64.ApplyOrtho.apply_p }
		.apply_q { lapack64.ApplyOrtho.apply_q }
	}
}

// Convert lapack64.ApplyOrtho to VSL ApplyOrtho
pub fn from_lapack64_apply_ortho(apply lapack64.ApplyOrtho) ApplyOrtho {
	return match apply {
		.apply_p { ApplyOrtho.apply_p }
		.apply_q { ApplyOrtho.apply_q }
	}
}

// Convert VSL GenOrtho to lapack64.GenOrtho
pub fn to_lapack64_gen_ortho(gen GenOrtho) lapack64.GenOrtho {
	return match gen {
		.generate_pt { lapack64.GenOrtho.generate_pt }
		.generate_q { lapack64.GenOrtho.generate_q }
	}
}

// Convert lapack64.GenOrtho to VSL GenOrtho
pub fn from_lapack64_gen_ortho(gen lapack64.GenOrtho) GenOrtho {
	return match gen {
		.generate_pt { GenOrtho.generate_pt }
		.generate_q { GenOrtho.generate_q }
	}
}

// Convert VSL SVDJob to lapack64.SVDJob
pub fn to_lapack64_svd_job(job SVDJob) lapack64.SVDJob {
	return match job {
		.svd_all { lapack64.SVDJob.svd_all }
		.svd_store { lapack64.SVDJob.svd_store }
		.svd_overwrite { lapack64.SVDJob.svd_overwrite }
		.svd_none { lapack64.SVDJob.svd_none }
	}
}

// Convert lapack64.SVDJob to VSL SVDJob
pub fn from_lapack64_svd_job(job lapack64.SVDJob) SVDJob {
	return match job {
		.svd_all { SVDJob.svd_all }
		.svd_store { SVDJob.svd_store }
		.svd_overwrite { SVDJob.svd_overwrite }
		.svd_none { SVDJob.svd_none }
	}
}

// Convert VSL GSVDJob to lapack64.GSVDJob
pub fn to_lapack64_gsvd_job(job GSVDJob) lapack64.GSVDJob {
	return match job {
		.gsvd_u { lapack64.GSVDJob.gsvd_u }
		.gsvd_v { lapack64.GSVDJob.gsvd_v }
		.gsvd_q { lapack64.GSVDJob.gsvd_q }
		.gsvd_unit { lapack64.GSVDJob.gsvd_unit }
		.gsvd_none { lapack64.GSVDJob.gsvd_none }
	}
}

// Convert lapack64.GSVDJob to VSL GSVDJob
pub fn from_lapack64_gsvd_job(job lapack64.GSVDJob) GSVDJob {
	return match job {
		.gsvd_u { GSVDJob.gsvd_u }
		.gsvd_v { GSVDJob.gsvd_v }
		.gsvd_q { GSVDJob.gsvd_q }
		.gsvd_unit { GSVDJob.gsvd_unit }
		.gsvd_none { GSVDJob.gsvd_none }
	}
}

// Convert VSL EigenVectorsComp to lapack64.EigenVectorsComp
pub fn to_lapack64_eigen_vectors_comp(comp EigenVectorsComp) lapack64.EigenVectorsComp {
	return match comp {
		.ev_orig { lapack64.EigenVectorsComp.ev_orig }
		.ev_tridiag { lapack64.EigenVectorsComp.ev_tridiag }
		.ev_comp_none { lapack64.EigenVectorsComp.ev_comp_none }
	}
}

// Convert lapack64.EigenVectorsComp to VSL EigenVectorsComp
pub fn from_lapack64_eigen_vectors_comp(comp lapack64.EigenVectorsComp) EigenVectorsComp {
	return match comp {
		.ev_orig { EigenVectorsComp.ev_orig }
		.ev_tridiag { EigenVectorsComp.ev_tridiag }
		.ev_comp_none { EigenVectorsComp.ev_comp_none }
	}
}

// Convert VSL EigenVectorsJob to lapack64.EigenVectorsJob
pub fn to_lapack64_eigen_vectors_job(job EigenVectorsJob) lapack64.EigenVectorsJob {
	return match job {
		.ev_compute { lapack64.EigenVectorsJob.ev_compute }
		.ev_none { lapack64.EigenVectorsJob.ev_none }
	}
}

// Convert lapack64.EigenVectorsJob to VSL EigenVectorsJob
pub fn from_lapack64_eigen_vectors_job(job lapack64.EigenVectorsJob) EigenVectorsJob {
	return match job {
		.ev_compute { EigenVectorsJob.ev_compute }
		.ev_none { EigenVectorsJob.ev_none }
	}
}

// Convert VSL LeftEigenVectorsJob to lapack64.LeftEigenVectorsJob
pub fn to_lapack64_left_eigen_vectors_job(job LeftEigenVectorsJob) lapack64.LeftEigenVectorsJob {
	return match job {
		.left_ev_compute { lapack64.LeftEigenVectorsJob.left_ev_compute }
		.left_ev_none { lapack64.LeftEigenVectorsJob.left_ev_none }
	}
}

// Convert lapack64.LeftEigenVectorsJob to VSL LeftEigenVectorsJob
pub fn from_lapack64_left_eigen_vectors_job(job lapack64.LeftEigenVectorsJob) LeftEigenVectorsJob {
	return match job {
		.left_ev_compute { LeftEigenVectorsJob.left_ev_compute }
		.left_ev_none { LeftEigenVectorsJob.left_ev_none }
	}
}

// Convert VSL RightEigenVectorsJob to lapack64.RightEigenVectorsJob
pub fn to_lapack64_right_eigen_vectors_job(job RightEigenVectorsJob) lapack64.RightEigenVectorsJob {
	return match job {
		.right_ev_compute { lapack64.RightEigenVectorsJob.right_ev_compute }
		.right_ev_none { lapack64.RightEigenVectorsJob.right_ev_none }
	}
}

// Convert lapack64.RightEigenVectorsJob to VSL RightEigenVectorsJob
pub fn from_lapack64_right_eigen_vectors_job(job lapack64.RightEigenVectorsJob) RightEigenVectorsJob {
	return match job {
		.right_ev_compute { RightEigenVectorsJob.right_ev_compute }
		.right_ev_none { RightEigenVectorsJob.right_ev_none }
	}
}

// Convert VSL BalanceJob to lapack64.BalanceJob
pub fn to_lapack64_balance_job(job BalanceJob) lapack64.BalanceJob {
	return match job {
		.permute { lapack64.BalanceJob.permute }
		.scale { lapack64.BalanceJob.scale }
		.permute_scale { lapack64.BalanceJob.permute_scale }
		.balance_none { lapack64.BalanceJob.balance_none }
	}
}

// Convert lapack64.BalanceJob to VSL BalanceJob
pub fn from_lapack64_balance_job(job lapack64.BalanceJob) BalanceJob {
	return match job {
		.permute { BalanceJob.permute }
		.scale { BalanceJob.scale }
		.permute_scale { BalanceJob.permute_scale }
		.balance_none { BalanceJob.balance_none }
	}
}

// Convert VSL SchurJob to lapack64.SchurJob
pub fn to_lapack64_schur_job(job SchurJob) lapack64.SchurJob {
	return match job {
		.eigenvalues_only { lapack64.SchurJob.eigenvalues_only }
		.eigenvalues_and_schur { lapack64.SchurJob.eigenvalues_and_schur }
	}
}

// Convert lapack64.SchurJob to VSL SchurJob
pub fn from_lapack64_schur_job(job lapack64.SchurJob) SchurJob {
	return match job {
		.eigenvalues_only { SchurJob.eigenvalues_only }
		.eigenvalues_and_schur { SchurJob.eigenvalues_and_schur }
	}
}

// Convert VSL SchurComp to lapack64.SchurComp
pub fn to_lapack64_schur_comp(comp SchurComp) lapack64.SchurComp {
	return match comp {
		.schur_orig { lapack64.SchurComp.schur_orig }
		.schur_hess { lapack64.SchurComp.schur_hess }
		.schur_none { lapack64.SchurComp.schur_none }
	}
}

// Convert lapack64.SchurComp to VSL SchurComp
pub fn from_lapack64_schur_comp(comp lapack64.SchurComp) SchurComp {
	return match comp {
		.schur_orig { SchurComp.schur_orig }
		.schur_hess { SchurComp.schur_hess }
		.schur_none { SchurComp.schur_none }
	}
}

// Convert VSL UpdateSchurComp to lapack64.UpdateSchurComp
pub fn to_lapack64_update_schur_comp(comp UpdateSchurComp) lapack64.UpdateSchurComp {
	return match comp {
		.update_schur { lapack64.UpdateSchurComp.update_schur }
		.update_schur_none { lapack64.UpdateSchurComp.update_schur_none }
	}
}

// Convert lapack64.UpdateSchurComp to VSL UpdateSchurComp
pub fn from_lapack64_update_schur_comp(comp lapack64.UpdateSchurComp) UpdateSchurComp {
	return match comp {
		.update_schur { UpdateSchurComp.update_schur }
		.update_schur_none { UpdateSchurComp.update_schur_none }
	}
}

// Convert VSL EigenVectorsSide to lapack64.EigenVectorsSide
pub fn to_lapack64_eigen_vectors_side(side EigenVectorsSide) lapack64.EigenVectorsSide {
	return match side {
		.ev_right { lapack64.EigenVectorsSide.ev_right }
		.ev_left { lapack64.EigenVectorsSide.ev_left }
		.ev_both { lapack64.EigenVectorsSide.ev_both }
	}
}

// Convert lapack64.EigenVectorsSide to VSL EigenVectorsSide
pub fn from_lapack64_eigen_vectors_side(side lapack64.EigenVectorsSide) EigenVectorsSide {
	return match side {
		.ev_right { EigenVectorsSide.ev_right }
		.ev_left { EigenVectorsSide.ev_left }
		.ev_both { EigenVectorsSide.ev_both }
	}
}

// Convert VSL EigenVectorsHowMany to lapack64.EigenVectorsHowMany
pub fn to_lapack64_eigen_vectors_how_many(how_many EigenVectorsHowMany) lapack64.EigenVectorsHowMany {
	return match how_many {
		.ev_all { lapack64.EigenVectorsHowMany.ev_all }
		.ev_all_mul_q { lapack64.EigenVectorsHowMany.ev_all_mul_q }
		.ev_selected { lapack64.EigenVectorsHowMany.ev_selected }
	}
}

// Convert lapack64.EigenVectorsHowMany to VSL EigenVectorsHowMany
pub fn from_lapack64_eigen_vectors_how_many(how_many lapack64.EigenVectorsHowMany) EigenVectorsHowMany {
	return match how_many {
		.ev_all { EigenVectorsHowMany.ev_all }
		.ev_all_mul_q { EigenVectorsHowMany.ev_all_mul_q }
		.ev_selected { EigenVectorsHowMany.ev_selected }
	}
}

// Convert VSL MaximizeNormXJob to lapack64.MaximizeNormXJob
pub fn to_lapack64_maximize_norm_x_job(job MaximizeNormXJob) lapack64.MaximizeNormXJob {
	return match job {
		.local_look_ahead { lapack64.MaximizeNormXJob.local_look_ahead }
		.normalized_null_vector { lapack64.MaximizeNormXJob.normalized_null_vector }
	}
}

// Convert lapack64.MaximizeNormXJob to VSL MaximizeNormXJob
pub fn from_lapack64_maximize_norm_x_job(job lapack64.MaximizeNormXJob) MaximizeNormXJob {
	return match job {
		.local_look_ahead { MaximizeNormXJob.local_look_ahead }
		.normalized_null_vector { MaximizeNormXJob.normalized_null_vector }
	}
}

// Convert VSL OrthoComp to lapack64.OrthoComp
pub fn to_lapack64_ortho_comp(comp OrthoComp) lapack64.OrthoComp {
	return match comp {
		.ortho_none { lapack64.OrthoComp.ortho_none }
		.ortho_explicit { lapack64.OrthoComp.ortho_explicit }
		.ortho_postmul { lapack64.OrthoComp.ortho_postmul }
	}
}

// Convert lapack64.OrthoComp to VSL OrthoComp
pub fn from_lapack64_ortho_comp(comp lapack64.OrthoComp) OrthoComp {
	return match comp {
		.ortho_none { OrthoComp.ortho_none }
		.ortho_explicit { OrthoComp.ortho_explicit }
		.ortho_postmul { OrthoComp.ortho_postmul }
	}
}

// ========================================================================
