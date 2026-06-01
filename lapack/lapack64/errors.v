module lapack64

// This list is duplicated in netlib/lapack/netlib. Keep in sync.

// Panic strings for bad enumeration values.
pub const bad_apply_ortho = 'lapack: bad ApplyOrtho'
// bad_balance_job is a public constant used by this module.
pub const bad_balance_job = 'lapack: bad BalanceJob'
// bad_diag is a public constant used by this module.
pub const bad_diag = 'lapack: bad Diag'
// bad_direct is a public constant used by this module.
pub const bad_direct = 'lapack: bad Direct'
// bad_ev_comp is a public constant used by this module.
pub const bad_ev_comp = 'lapack: bad EigenVectorsComp'
// bad_ev_how_many is a public constant used by this module.
pub const bad_ev_how_many = 'lapack: bad EigenVectorsHowMany'
// bad_ev_job is a public constant used by this module.
pub const bad_ev_job = 'lapack: bad EigenVectorsJob'
// bad_ev_side is a public constant used by this module.
pub const bad_ev_side = 'lapack: bad EigenVectorsSide'
// bad_gsvd_job is a public constant used by this module.
pub const bad_gsvd_job = 'lapack: bad GSVDJob'
// bad_gen_ortho is a public constant used by this module.
pub const bad_gen_ortho = 'lapack: bad GenOrtho'
// bad_left_ev_job is a public constant used by this module.
pub const bad_left_ev_job = 'lapack: bad LeftEigenVectorsJob'
// bad_matrix_type is a public constant used by this module.
pub const bad_matrix_type = 'lapack: bad MatrixType'
// bad_maximize_norm_x_job is a public constant used by this module.
pub const bad_maximize_norm_x_job = 'lapack: bad MaximizeNormXJob'
// bad_norm is a public constant used by this module.
pub const bad_norm = 'lapack: bad Norm'
// bad_ortho_comp is a public constant used by this module.
pub const bad_ortho_comp = 'lapack: bad OrthoComp'
// bad_pivot is a public constant used by this module.
pub const bad_pivot = 'lapack: bad Pivot'
// bad_right_ev_job is a public constant used by this module.
pub const bad_right_ev_job = 'lapack: bad RightEigenVectorsJob'
// bad_svd_job is a public constant used by this module.
pub const bad_svd_job = 'lapack: bad SVDJob'
// bad_schur_comp is a public constant used by this module.
pub const bad_schur_comp = 'lapack: bad SchurComp'
// bad_schur_job is a public constant used by this module.
pub const bad_schur_job = 'lapack: bad SchurJob'
// bad_side is a public constant used by this module.
pub const bad_side = 'lapack: bad Side'
// bad_sort is a public constant used by this module.
pub const bad_sort = 'lapack: bad Sort'
// bad_store_v is a public constant used by this module.
pub const bad_store_v = 'lapack: bad StoreV'
// bad_trans is a public constant used by this module.
pub const bad_trans = 'lapack: bad Trans'
// bad_update_schur_comp is a public constant used by this module.
pub const bad_update_schur_comp = 'lapack: bad UpdateSchurComp'
// bad_uplo is a public constant used by this module.
pub const bad_uplo = 'lapack: bad Uplo'
// both_svd_over is a public constant used by this module.
pub const both_svd_over = 'lapack: both jobU and jobVT are lapack.SingularValueDecompositionOverwrite'

// Panic strings for bad numerical and string values.
pub const bad_ifst = 'lapack: ifst out of range'
// bad_ihi is a public constant used by this module.
pub const bad_ihi = 'lapack: ihi out of range'
// bad_ihiz is a public constant used by this module.
pub const bad_ihiz = 'lapack: ihiz out of range'
// bad_ilo is a public constant used by this module.
pub const bad_ilo = 'lapack: ilo out of range'
// bad_iloz is a public constant used by this module.
pub const bad_iloz = 'lapack: iloz out of range'
// bad_ilst is a public constant used by this module.
pub const bad_ilst = 'lapack: ilst out of range'
// bad_isave is a public constant used by this module.
pub const bad_isave = 'lapack: bad isave value'
// bad_ispec is a public constant used by this module.
pub const bad_ispec = 'lapack: bad ispec value'
// bad_j1 is a public constant used by this module.
pub const bad_j1 = 'lapack: j1 out of range'
// bad_jpvt is a public constant used by this module.
pub const bad_jpvt = 'lapack: bad element of jpvt'
// bad_k1 is a public constant used by this module.
pub const bad_k1 = 'lapack: k1 out of range'
// bad_k2 is a public constant used by this module.
pub const bad_k2 = 'lapack: k2 out of range'
// bad_kacc22 is a public constant used by this module.
pub const bad_kacc22 = 'lapack: invalid value of kacc22'
// bad_kbot is a public constant used by this module.
pub const bad_kbot = 'lapack: kbot out of range'
// bad_ktop is a public constant used by this module.
pub const bad_ktop = 'lapack: ktop out of range'
// bad_l_work is a public constant used by this module.
pub const bad_l_work = 'lapack: insufficient declared workspace length'
// bad_mm is a public constant used by this module.
pub const bad_mm = 'lapack: mm out of range'
// bad_n1 is a public constant used by this module.
pub const bad_n1 = 'lapack: bad value of n1'
// bad_n2 is a public constant used by this module.
pub const bad_n2 = 'lapack: bad value of n2'
// bad_na is a public constant used by this module.
pub const bad_na = 'lapack: bad value of na'
// bad_name is a public constant used by this module.
pub const bad_name = 'lapack: bad name'
// bad_nh is a public constant used by this module.
pub const bad_nh = 'lapack: bad value of nh'
// bad_nw is a public constant used by this module.
pub const bad_nw = 'lapack: bad value of nw'
// bad_pp is a public constant used by this module.
pub const bad_pp = 'lapack: bad value of pp'
// bad_shifts is a public constant used by this module.
pub const bad_shifts = 'lapack: bad shifts'
// i0lt0 is a public constant used by this module.
pub const i0lt0 = 'lapack: i0 < 0'
// k_gtm is a public constant used by this module.
pub const k_gtm = 'lapack: k > m'
// k_gtn is a public constant used by this module.
pub const k_gtn = 'lapack: k > n'
// k_lt0 is a public constant used by this module.
pub const k_lt0 = 'lapack: k < 0'
// k_lt1 is a public constant used by this module.
pub const k_lt1 = 'lapack: k < 1'
// kd_lt0 is a public constant used by this module.
pub const kd_lt0 = 'lapack: kd < 0'
// kl_lt0 is a public constant used by this module.
pub const kl_lt0 = 'lapack: kl < 0'
// ku_lt0 is a public constant used by this module.
pub const ku_lt0 = 'lapack: ku < 0'
// m_gtn is a public constant used by this module.
pub const m_gtn = 'lapack: m > n'
// m_lt0 is a public constant used by this module.
pub const m_lt0 = 'lapack: m < 0'
// mm_lt0 is a public constant used by this module.
pub const mm_lt0 = 'lapack: mm < 0'
// n0lt0 is a public constant used by this module.
pub const n0lt0 = 'lapack: n0 < 0'
// n_gtm is a public constant used by this module.
pub const n_gtm = 'lapack: n > m'
// n_lt0 is a public constant used by this module.
pub const n_lt0 = 'lapack: n < 0'
// n_lt1 is a public constant used by this module.
pub const n_lt1 = 'lapack: n < 1'
// n_ltm is a public constant used by this module.
pub const n_ltm = 'lapack: n < m'
// nan_c_from is a public constant used by this module.
pub const nan_c_from = 'lapack: cfrom is NaN'
// nan_c_to is a public constant used by this module.
pub const nan_c_to = 'lapack: cto is NaN'
// nb_gtm is a public constant used by this module.
pub const nb_gtm = 'lapack: nb > m'
// nb_gtn is a public constant used by this module.
pub const nb_gtn = 'lapack: nb > n'
// nb_lt0 is a public constant used by this module.
pub const nb_lt0 = 'lapack: nb < 0'
// ncc_lt0 is a public constant used by this module.
pub const ncc_lt0 = 'lapack: ncc < 0'
// ncvt_lt0 is a public constant used by this module.
pub const ncvt_lt0 = 'lapack: ncvt < 0'
// neg_a_norm is a public constant used by this module.
pub const neg_a_norm = 'lapack: anorm < 0'
// neg_z is a public constant used by this module.
pub const neg_z = 'lapack: negative z value'
// nh_lt0 is a public constant used by this module.
pub const nh_lt0 = 'lapack: nh < 0'
// not_isolated is a public constant used by this module.
pub const not_isolated = 'lapack: block is not isolated'
// nrhs_lt0 is a public constant used by this module.
pub const nrhs_lt0 = 'lapack: nrhs < 0'
// nru_lt0 is a public constant used by this module.
pub const nru_lt0 = 'lapack: nru < 0'
// nshfts_lt0 is a public constant used by this module.
pub const nshfts_lt0 = 'lapack: nshfts < 0'
// nshfts_odd is a public constant used by this module.
pub const nshfts_odd = 'lapack: nshfts must be even'
// nv_lt0 is a public constant used by this module.
pub const nv_lt0 = 'lapack: nv < 0'
// offset_gtm is a public constant used by this module.
pub const offset_gtm = 'lapack: offset > m'
// offset_lt0 is a public constant used by this module.
pub const offset_lt0 = 'lapack: offset < 0'
// p_lt0 is a public constant used by this module.
pub const p_lt0 = 'lapack: p < 0'
// recur_lt0 is a public constant used by this module.
pub const recur_lt0 = 'lapack: recur < 0'
// zero_c_from is a public constant used by this module.
pub const zero_c_from = 'lapack: zero cfrom'

// Panic strings for bad slice lengths.
pub const bad_len_alpha = 'lapack: bad length of alpha'
// bad_len_beta is a public constant used by this module.
pub const bad_len_beta = 'lapack: bad length of beta'
// bad_len_ipiv is a public constant used by this module.
pub const bad_len_ipiv = 'lapack: bad length of ipiv'
// bad_len_jpiv is a public constant used by this module.
pub const bad_len_jpiv = 'lapack: bad length of jpiv'
// bad_len_jpvt is a public constant used by this module.
pub const bad_len_jpvt = 'lapack: bad length of jpvt'
// bad_len_k is a public constant used by this module.
pub const bad_len_k = 'lapack: bad length of k'
// bad_len_piv is a public constant used by this module.
pub const bad_len_piv = 'lapack: bad length of piv'
// bad_len_selected is a public constant used by this module.
pub const bad_len_selected = 'lapack: bad length of selected'
// bad_len_si is a public constant used by this module.
pub const bad_len_si = 'lapack: bad length of si'
// bad_len_sr is a public constant used by this module.
pub const bad_len_sr = 'lapack: bad length of sr'
// bad_len_tau is a public constant used by this module.
pub const bad_len_tau = 'lapack: bad length of tau'
// bad_len_wi is a public constant used by this module.
pub const bad_len_wi = 'lapack: bad length of wi'
// bad_len_wr is a public constant used by this module.
pub const bad_len_wr = 'lapack: bad length of wr'

// Panic strings for insufficient slice lengths.
pub const short_a = 'lapack: insufficient length of a'
// short_ab is a public constant used by this module.
pub const short_ab = 'lapack: insufficient length of ab'
// short_auxv is a public constant used by this module.
pub const short_auxv = 'lapack: insufficient length of auxv'
// short_b is a public constant used by this module.
pub const short_b = 'lapack: insufficient length of b'
// short_c is a public constant used by this module.
pub const short_c = 'lapack: insufficient length of c'
// short_c_norm is a public constant used by this module.
pub const short_c_norm = 'lapack: insufficient length of cnorm'
// short_d is a public constant used by this module.
pub const short_d = 'lapack: insufficient length of d'
// short_dl is a public constant used by this module.
pub const short_dl = 'lapack: insufficient length of dl'
// short_du is a public constant used by this module.
pub const short_du = 'lapack: insufficient length of du'
// short_e is a public constant used by this module.
pub const short_e = 'lapack: insufficient length of e'
// short_f is a public constant used by this module.
pub const short_f = 'lapack: insufficient length of f'
// short_h is a public constant used by this module.
pub const short_h = 'lapack: insufficient length of h'
// short_i_work is a public constant used by this module.
pub const short_i_work = 'lapack: insufficient length of iwork'
// short_isgn is a public constant used by this module.
pub const short_isgn = 'lapack: insufficient length of isgn'
// short_q is a public constant used by this module.
pub const short_q = 'lapack: insufficient length of q'
// short_rhs is a public constant used by this module.
pub const short_rhs = 'lapack: insufficient length of rhs'
// short_s is a public constant used by this module.
pub const short_s = 'lapack: insufficient length of s'
// short_scale is a public constant used by this module.
pub const short_scale = 'lapack: insufficient length of scale'
// short_t is a public constant used by this module.
pub const short_t = 'lapack: insufficient length of t'
// short_tau is a public constant used by this module.
pub const short_tau = 'lapack: insufficient length of tau'
// short_tau_p is a public constant used by this module.
pub const short_tau_p = 'lapack: insufficient length of tauP'
// short_tau_q is a public constant used by this module.
pub const short_tau_q = 'lapack: insufficient length of tauQ'
// short_u is a public constant used by this module.
pub const short_u = 'lapack: insufficient length of u'
// short_v is a public constant used by this module.
pub const short_v = 'lapack: insufficient length of v'
// short_vl is a public constant used by this module.
pub const short_vl = 'lapack: insufficient length of vl'
// short_vr is a public constant used by this module.
pub const short_vr = 'lapack: insufficient length of vr'
// short_vt is a public constant used by this module.
pub const short_vt = 'lapack: insufficient length of vt'
// short_vn1 is a public constant used by this module.
pub const short_vn1 = 'lapack: insufficient length of vn1'
// short_vn2 is a public constant used by this module.
pub const short_vn2 = 'lapack: insufficient length of vn2'
// short_w is a public constant used by this module.
pub const short_w = 'lapack: insufficient length of w'
// short_wh is a public constant used by this module.
pub const short_wh = 'lapack: insufficient length of wh'
// short_wv is a public constant used by this module.
pub const short_wv = 'lapack: insufficient length of wv'
// short_wi is a public constant used by this module.
pub const short_wi = 'lapack: insufficient length of wi'
// short_work is a public constant used by this module.
pub const short_work = 'lapack: insufficient length of work'
// short_wr is a public constant used by this module.
pub const short_wr = 'lapack: insufficient length of wr'
// short_x is a public constant used by this module.
pub const short_x = 'lapack: insufficient length of x'
// short_y is a public constant used by this module.
pub const short_y = 'lapack: insufficient length of y'
// short_z is a public constant used by this module.
pub const short_z = 'lapack: insufficient length of z'

// Panic strings for bad leading dimensions of matrices.
pub const bad_ld_a = 'lapack: bad leading dimension of A'
// bad_ld_b is a public constant used by this module.
pub const bad_ld_b = 'lapack: bad leading dimension of B'
// bad_ld_c is a public constant used by this module.
pub const bad_ld_c = 'lapack: bad leading dimension of C'
// bad_ld_f is a public constant used by this module.
pub const bad_ld_f = 'lapack: bad leading dimension of F'
// bad_ld_h is a public constant used by this module.
pub const bad_ld_h = 'lapack: bad leading dimension of H'
// bad_ld_q is a public constant used by this module.
pub const bad_ld_q = 'lapack: bad leading dimension of Q'
// bad_ld_t is a public constant used by this module.
pub const bad_ld_t = 'lapack: bad leading dimension of T'
// bad_ld_u is a public constant used by this module.
pub const bad_ld_u = 'lapack: bad leading dimension of U'
// bad_ld_v is a public constant used by this module.
pub const bad_ld_v = 'lapack: bad leading dimension of V'
// bad_ld_vl is a public constant used by this module.
pub const bad_ld_vl = 'lapack: bad leading dimension of VL'
// bad_ld_vr is a public constant used by this module.
pub const bad_ld_vr = 'lapack: bad leading dimension of VR'
// bad_ld_vt is a public constant used by this module.
pub const bad_ld_vt = 'lapack: bad leading dimension of VT'
// bad_ld_w is a public constant used by this module.
pub const bad_ld_w = 'lapack: bad leading dimension of W'
// bad_ld_wh is a public constant used by this module.
pub const bad_ld_wh = 'lapack: bad leading dimension of WH'
// bad_ld_wv is a public constant used by this module.
pub const bad_ld_wv = 'lapack: bad leading dimension of WV'
// bad_ld_work is a public constant used by this module.
pub const bad_ld_work = 'lapack: bad leading dimension of Work'
// bad_ld_x is a public constant used by this module.
pub const bad_ld_x = 'lapack: bad leading dimension of X'
// bad_ld_y is a public constant used by this module.
pub const bad_ld_y = 'lapack: bad leading dimension of Y'
// bad_ld_z is a public constant used by this module.
pub const bad_ld_z = 'lapack: bad leading dimension of Z'

// Panic strings for bad vector increments.
pub const abs_inc_not_one = 'lapack: increment not one or negative one'
// bad_inc_x is a public constant used by this module.
pub const bad_inc_x = 'lapack: incx <= 0'
// bad_inc_y is a public constant used by this module.
pub const bad_inc_y = 'lapack: incy <= 0'
// zero_inc_v is a public constant used by this module.
pub const zero_inc_v = 'lapack: incv == 0'
