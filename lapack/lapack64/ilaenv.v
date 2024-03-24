module lapack64

// ilaenv returns algorithm tuning parameters for the algorithm given by the
// input string. ispec specifies the parameter to return:
//
//	1: The optimal block size for a blocked algorithm.
//	2: The minimum block size for a blocked algorithm.
//	3: The block size of unprocessed data at which a blocked algorithm should
//	   crossover to an unblocked version.
//	4: The number of shifts.
//	5: The minimum column dimension for blocking to be used.
//	6: The crossover point for SVD (to use QR factorization or not).
//	7: The number of processors.
//	8: The crossover point for multi-shift in QR and QZ methods for non-symmetric eigenvalue problems.
//	9: Maximum size of the subproblems in divide-and-conquer algorithms.
//	10: ieee infinity and NaN arithmetic can be trusted not to trap.
//	11: ieee infinity arithmetic can be trusted not to trap.
//	12...16: parameters for Dhseqr and related functions. See Iparmq for more
//	         information.
//
// ilaenv is an internal routine. It is exported for testing purposes.
fn ilaenv(ispec int, name string, opts string, n1 int, n2 int, n3 int, n4 int) int {
	// TODO(btracey): Replace this with a constant lookup? A list of constants?
	sname := name[0] == `S` || name[0] == `D`
	cname := name[0] == `C` || name[0] == `Z`
	if !sname && !cname {
		panic(bad_name)
	}

	c2 := name[1..3]
	c3 := name[3..6]
	c4 := c3[1..3]

	match ispec {
		1 {
			match c2 {
				'GE' {
					match c3 {
						'TRF', 'TRI' {
							return 64
						}
						'QRF', 'RQF', 'LQF', 'QLF', 'HRD', 'BRD' {
							return 32
						}
						else {
							panic(bad_name)
						}
					}
				}
				'PO' {
					match c3 {
						'TRF' {
							return 64
						}
						else {
							panic(bad_name)
						}
					}
				}
				'SY', 'HE' {
					match c3 {
						'TRF' {
							return 64
						}
						'TRD', 'GST' {
							return 32
						}
						else {
							panic(bad_name)
						}
					}
				}
				'OR', 'UN' {
					match c3[0] {
						'G', 'M' {
							match c3[1..] {
								'QR', 'RQ', 'LQ', 'QL', 'HR', 'TR', 'BR' {
									return 32
								}
								else {
									panic(bad_name)
								}
							}
						}
						else {
							panic(bad_name)
						}
					}
				}
				'GB', 'PB' {
					// Assuming n4 and n2 are defined elsewhere in your code
					match c3 {
						'TRF' {
							// Replace `n4` and `n2` with actual variables
							if sname {
								// if n4 <= 64 {
								//     return 1
								// }
								return 32
							}
							// if n4 <= 64 {
							//     return 1
							// }
							return 32
						}
						else {
							panic(bad_name)
						}
					}
				}
				'PT', 'TR', 'LA' {
					// Additional cases as per your original logic
				}
				'ST' {
					if sname && c3 == 'EBZ' {
						return 1
					}
					panic(bad_name)
				}
				else {
					panic(bad_name)
				}
			}
		}
		2 {
			match c2 {
				'GE' {
					match c3 {
						'QRF', 'RQF', 'LQF', 'QLF', 'HRD', 'BRD', 'TRI' {
							if sname {
								return 2
							}
							return 2
						}
						else {
							panic(bad_name)
						}
					}
				}
				'SY' {
					match c3 {
						'TRF' {
							if sname {
								return 8
							}
							return 8
						}
						'TRD' {
							if sname {
								return 2
							}
							panic(bad_name)
						}
						else {
							panic(bad_name)
						}
					}
				}
				'HE' {
					if c3 == 'TRD' {
						return 2
					}
					panic(bad_name)
				}
				'OR', 'UN' {
					if !sname {
						panic(bad_name)
					}
					match c3[0] {
						'G', 'M' {
							match c4 {
								'QR', 'RQ', 'LQ', 'QL', 'HR', 'TR', 'BR' {
									return 2
								}
								else {
									panic(bad_name)
								}
							}
						}
						else {
							panic(bad_name)
						}
					}
				}
				else {
					panic(bad_name)
				}
			}
		}
		3 {
			match c2 {
				'GE' {
					match c3 {
						'QRF', 'RQF', 'LQF', 'QLF', 'HRD', 'BRD' {
							if sname {
								return 128
							}
							return 128
						}
						else {
							panic(bad_name)
						}
					}
				}
				'SY', 'HE' {
					if c3 == 'TRD' {
						return 32
					}
					panic(bad_name)
				}
				'OR', 'UN' {
					match c3[0] {
						'G' {
							match c4 {
								'QR', 'RQ', 'LQ', 'QL', 'HR', 'TR', 'BR' {
									return 128
								}
								else {
									panic(bad_name)
								}
							}
						}
						else {
							panic(bad_name)
						}
					}
				}
				else {
					panic(bad_name)
				}
			}
		}
		4 {
			// Used by xHSEQR
			return 6
		}
		5 {
			// Not used
			return 2
		}
		6 {
			// Used by xGELSS and xGESVD
			// Assuming n1 and n2 are defined elsewhere in your code
			// Replace `min(n1, n2)` with actual min calculation or function
			return int(f64(min(n1, n2)) * 1.6)
		}
		7 {
			// Not used
			return 1
		}
		8 {
			// Used by xHSEQR
			return 50
		}
		9 {
			// Used by xGELSD and xGESDD
			return 25
		}
		10, 11 {
			// Go guarantees ieee
			return 1
		}
		12, 13, 14, 15, 16 {
			// dhseqr and related functions for eigenvalue problems.
			return iparmq(ispec, name, opts, n1, n2, n3, n4)
		}
		else {
			panic(bad_ispec)
		}
	}
	return 0
}
