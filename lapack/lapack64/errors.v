module lapack64

// This list is duplicated in netlib/lapack/netlib. Keep in sync.

// Panic strings for bad enumeration values.
pub const bad_apply_ortho = 'lapack: bad ApplyOrtho'
pub const bad_balance_job = 'lapack: bad BalanceJob'
pub const bad_diag = 'lapack: bad Diag'
pub const bad_direct = 'lapack: bad Direct'
pub const bad_ev_comp = 'lapack: bad EigenVectorsComp'
pub const bad_ev_how_many = 'lapack: bad EigenVectorsHowMany'
pub const bad_ev_job = 'lapack: bad EigenVectorsJob'
pub const bad_ev_side = 'lapack: bad EigenVectorsSide'
pub const bad_gsvd_job = 'lapack: bad GSVDJob'
pub const bad_gen_ortho = 'lapack: bad GenOrtho'
pub const bad_left_ev_job = 'lapack: bad LeftEigenVectorsJob'
pub const bad_matrix_type = 'lapack: bad MatrixType'
pub const bad_maximize_norm_x_job = 'lapack: bad MaximizeNormXJob'
pub const bad_norm = 'lapack: bad Norm'
pub const bad_ortho_comp = 'lapack: bad OrthoComp'
pub const bad_pivot = 'lapack: bad Pivot'
pub const bad_right_ev_job = 'lapack: bad RightEigenVectorsJob'
pub const bad_svd_job = 'lapack: bad SVDJob'
pub const bad_schur_comp = 'lapack: bad SchurComp'
pub const bad_schur_job = 'lapack: bad SchurJob'
pub const bad_side = 'lapack: bad Side'
pub const bad_sort = 'lapack: bad Sort'
pub const bad_store_v = 'lapack: bad StoreV'
pub const bad_trans = 'lapack: bad Trans'
pub const bad_update_schur_comp = 'lapack: bad UpdateSchurComp'
pub const bad_uplo = 'lapack: bad Uplo'
pub const both_svd_over = 'lapack: both jobU and jobVT are lapack.SingularValueDecompositionOverwrite'

// Panic strings for bad numerical and string values.
pub const bad_ifst = 'lapack: ifst out of range'
pub const bad_ihi = 'lapack: ihi out of range'
pub const bad_ihiz = 'lapack: ihiz out of range'
pub const bad_ilo = 'lapack: ilo out of range'
pub const bad_iloz = 'lapack: iloz out of range'
pub const bad_ilst = 'lapack: ilst out of range'
pub const bad_isave = 'lapack: bad isave value'
pub const bad_ispec = 'lapack: bad ispec value'
pub const bad_j1 = 'lapack: j1 out of range'
pub const bad_jpvt = 'lapack: bad element of jpvt'
pub const bad_k1 = 'lapack: k1 out of range'
pub const bad_k2 = 'lapack: k2 out of range'
pub const bad_kacc22 = 'lapack: invalid value of kacc22'
pub const bad_kbot = 'lapack: kbot out of range'
pub const bad_ktop = 'lapack: ktop out of range'
pub const bad_l_work = 'lapack: insufficient declared workspace length'
pub const bad_mm = 'lapack: mm out of range'
pub const bad_n1 = 'lapack: bad value of n1'
pub const bad_n2 = 'lapack: bad value of n2'
pub const bad_na = 'lapack: bad value of na'
pub const bad_name = 'lapack: bad name'
pub const bad_nh = 'lapack: bad value of nh'
pub const bad_nw = 'lapack: bad value of nw'
pub const bad_pp = 'lapack: bad value of pp'
pub const bad_shifts = 'lapack: bad shifts'
pub const i0lt0 = 'lapack: i0 < 0'
pub const k_gtm = 'lapack: k > m'
pub const k_gtn = 'lapack: k > n'
pub const k_lt0 = 'lapack: k < 0'
pub const k_lt1 = 'lapack: k < 1'
pub const kd_lt0 = 'lapack: kd < 0'
pub const kl_lt0 = 'lapack: kl < 0'
pub const ku_lt0 = 'lapack: ku < 0'
pub const m_gtn = 'lapack: m > n'
pub const m_lt0 = 'lapack: m < 0'
pub const mm_lt0 = 'lapack: mm < 0'
pub const n0lt0 = 'lapack: n0 < 0'
pub const n_gtm = 'lapack: n > m'
pub const n_lt0 = 'lapack: n < 0'
pub const n_lt1 = 'lapack: n < 1'
pub const n_ltm = 'lapack: n < m'
pub const nan_c_from = 'lapack: cfrom is NaN'
pub const nan_c_to = 'lapack: cto is NaN'
pub const nb_gtm = 'lapack: nb > m'
pub const nb_gtn = 'lapack: nb > n'
pub const nb_lt0 = 'lapack: nb < 0'
pub const ncc_lt0 = 'lapack: ncc < 0'
pub const ncvt_lt0 = 'lapack: ncvt < 0'
pub const neg_a_norm = 'lapack: anorm < 0'
pub const neg_z = 'lapack: negative z value'
pub const nh_lt0 = 'lapack: nh < 0'
pub const not_isolated = 'lapack: block is not isolated'
pub const nrhs_lt0 = 'lapack: nrhs < 0'
pub const nru_lt0 = 'lapack: nru < 0'
pub const nshfts_lt0 = 'lapack: nshfts < 0'
pub const nshfts_odd = 'lapack: nshfts must be even'
pub const nv_lt0 = 'lapack: nv < 0'
pub const offset_gtm = 'lapack: offset > m'
pub const offset_lt0 = 'lapack: offset < 0'
pub const p_lt0 = 'lapack: p < 0'
pub const recur_lt0 = 'lapack: recur < 0'
pub const zero_c_from = 'lapack: zero cfrom'

// Panic strings for bad slice lengths.
pub const bad_len_alpha = 'lapack: bad length of alpha'
pub const bad_len_beta = 'lapack: bad length of beta'
pub const bad_len_ipiv = 'lapack: bad length of ipiv'
pub const bad_len_jpiv = 'lapack: bad length of jpiv'
pub const bad_len_jpvt = 'lapack: bad length of jpvt'
pub const bad_len_k = 'lapack: bad length of k'
pub const bad_len_piv = 'lapack: bad length of piv'
pub const bad_len_selected = 'lapack: bad length of selected'
pub const bad_len_si = 'lapack: bad length of si'
pub const bad_len_sr = 'lapack: bad length of sr'
pub const bad_len_tau = 'lapack: bad length of tau'
pub const bad_len_wi = 'lapack: bad length of wi'
pub const bad_len_wr = 'lapack: bad length of wr'

// Panic strings for insufficient slice lengths.
pub const short_a = 'lapack: insufficient length of a'
pub const short_ab = 'lapack: insufficient length of ab'
pub const short_auxv = 'lapack: insufficient length of auxv'
pub const short_b = 'lapack: insufficient length of b'
pub const short_c = 'lapack: insufficient length of c'
pub const short_c_norm = 'lapack: insufficient length of cnorm'
pub const short_d = 'lapack: insufficient length of d'
pub const short_dl = 'lapack: insufficient length of dl'
pub const short_du = 'lapack: insufficient length of du'
pub const short_e = 'lapack: insufficient length of e'
pub const short_f = 'lapack: insufficient length of f'
pub const short_h = 'lapack: insufficient length of h'
pub const short_i_work = 'lapack: insufficient length of iwork'
pub const short_isgn = 'lapack: insufficient length of isgn'
pub const short_q = 'lapack: insufficient length of q'
pub const short_rhs = 'lapack: insufficient length of rhs'
pub const short_s = 'lapack: insufficient length of s'
pub const short_scale = 'lapack: insufficient length of scale'
pub const short_t = 'lapack: insufficient length of t'
pub const short_tau = 'lapack: insufficient length of tau'
pub const short_tau_p = 'lapack: insufficient length of tauP'
pub const short_tau_q = 'lapack: insufficient length of tauQ'
pub const short_u = 'lapack: insufficient length of u'
pub const short_v = 'lapack: insufficient length of v'
pub const short_vl = 'lapack: insufficient length of vl'
pub const short_vr = 'lapack: insufficient length of vr'
pub const short_vt = 'lapack: insufficient length of vt'
pub const short_vn1 = 'lapack: insufficient length of vn1'
pub const short_vn2 = 'lapack: insufficient length of vn2'
pub const short_w = 'lapack: insufficient length of w'
pub const short_wh = 'lapack: insufficient length of wh'
pub const short_wv = 'lapack: insufficient length of wv'
pub const short_wi = 'lapack: insufficient length of wi'
pub const short_work = 'lapack: insufficient length of work'
pub const short_wr = 'lapack: insufficient length of wr'
pub const short_x = 'lapack: insufficient length of x'
pub const short_y = 'lapack: insufficient length of y'
pub const short_z = 'lapack: insufficient length of z'

// Panic strings for bad leading dimensions of matrices.
pub const bad_ld_a = 'lapack: bad leading dimension of A'
pub const bad_ld_b = 'lapack: bad leading dimension of B'
pub const bad_ld_c = 'lapack: bad leading dimension of C'
pub const bad_ld_f = 'lapack: bad leading dimension of F'
pub const bad_ld_h = 'lapack: bad leading dimension of H'
pub const bad_ld_q = 'lapack: bad leading dimension of Q'
pub const bad_ld_t = 'lapack: bad leading dimension of T'
pub const bad_ld_u = 'lapack: bad leading dimension of U'
pub const bad_ld_v = 'lapack: bad leading dimension of V'
pub const bad_ld_vl = 'lapack: bad leading dimension of VL'
pub const bad_ld_vr = 'lapack: bad leading dimension of VR'
pub const bad_ld_vt = 'lapack: bad leading dimension of VT'
pub const bad_ld_w = 'lapack: bad leading dimension of W'
pub const bad_ld_wh = 'lapack: bad leading dimension of WH'
pub const bad_ld_wv = 'lapack: bad leading dimension of WV'
pub const bad_ld_work = 'lapack: bad leading dimension of Work'
pub const bad_ld_x = 'lapack: bad leading dimension of X'
pub const bad_ld_y = 'lapack: bad leading dimension of Y'
pub const bad_ld_z = 'lapack: bad leading dimension of Z'

// Panic strings for bad vector increments.
pub const abs_inc_not_one = 'lapack: increment not one or negative one'
pub const bad_inc_x = 'lapack: incx <= 0'
pub const bad_inc_y = 'lapack: incy <= 0'
pub const zero_inc_v = 'lapack: incv == 0'