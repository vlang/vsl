module float64

import math

const (
	dgemv_tests = [
		DgemvCase{ // 1x1
			m: 1
			n: 1
			a: [4.1]
			x: [2.2]
			y: [6.8]
			no_trans: [// (1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0]
				want_rev_x: [0.0]
				want_rev_y: [0.0]
				want_rev_xy: [0.0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [6.8]
				want_rev_x: [6.8]
				want_rev_y: [6.8]
				want_rev_xy: [6.8]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [9.02]
				want_rev_x: [9.02]
				want_rev_y: [9.02]
				want_rev_xy: [9.02]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [31.36]
				want_rev_x: [31.36]
				want_rev_y: [31.36]
				want_rev_xy: [31.36]
			}]
			trans: [// (1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0]
				want_rev_x: [0.0]
				want_rev_y: [0.0]
				want_rev_xy: [0.0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [2.2]
				want_rev_x: [2.2]
				want_rev_y: [2.2]
				want_rev_xy: [2.2]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [27.88]
				want_rev_x: [27.88]
				want_rev_y: [27.88]
				want_rev_xy: [27.88]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [209.84]
				want_rev_x: [209.84]
				want_rev_y: [209.84]
				want_rev_xy: [209.84]
			}]
		},
		DgemvCase{ // 3x2
			m: 3
			n: 2
			a: [4.67, 2.75, 0.48, 1.21, 2.28, 2.82]
			x: [3.38, 3]
			y: [2.8, 1.71, 2.64]
			no_trans: [// (2x2, 1x2)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0]
				want_rev_x: [0.0, 0, 0]
				want_rev_y: [0.0, 0, 0]
				want_rev_xy: [0.0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [2.8, 1.71, 2.64]
				want_rev_x: [2.8, 1.71, 2.64]
				want_rev_y: [2.8, 1.71, 2.64]
				want_rev_xy: [2.8, 1.71, 2.64]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [24.0346, 5.2524, 16.1664]
				want_rev_x: [23.305, 5.5298, 16.3716]
				want_rev_y: [16.1664, 5.2524, 24.0346]
				want_rev_xy: [16.3716, 5.5298, 23.305]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [175.4768, 31.7592, 113.4912]
				want_rev_x: [169.64, 33.9784, 115.1328]
				want_rev_y: [112.5312, 31.7592, 176.4368]
				want_rev_xy: [114.1728, 33.9784, 170.6]
			}]
			trans: [// (2x2)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0]
				want_rev_x: [0.0, 0]
				want_rev_y: [0.0, 0]
				want_rev_xy: [0.0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [3.38, 3]
				want_rev_x: [3.38, 3]
				want_rev_y: [3.38, 3]
				want_rev_xy: [3.38, 3]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [19.916, 17.2139]
				want_rev_x: [19.5336, 17.2251]
				want_rev_y: [17.2139, 19.916]
				want_rev_xy: [17.2251, 19.5336]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [139.048, 119.7112]
				want_rev_x: [135.9888, 119.8008]
				want_rev_y: [117.4312, 141.328]
				want_rev_xy: [117.5208, 138.2688]
			}]
		},
		DgemvCase{ // 3x3
			m: 3
			n: 3
			a: [4.38, 4.4, 4.26, 4.18, 0.56, 2.57, 2.59, 2.07, 0.46]
			x: [4.82, 1.82, 1.12]
			y: [0.24, 1.41, 3.45]
			no_trans: [// (2x2, 2x1, 1x2, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0]
				want_rev_x: [0.0, 0, 0]
				want_rev_y: [0.0, 0, 0]
				want_rev_xy: [0.0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [0.24, 1.41, 3.45]
				want_rev_x: [0.24, 1.41, 3.45]
				want_rev_y: [0.24, 1.41, 3.45]
				want_rev_xy: [0.24, 1.41, 3.45]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [33.8908, 24.0452, 16.7664]
				want_rev_x: [33.4468, 18.0882, 8.8854]
				want_rev_y: [16.7664, 24.0452, 33.8908]
				want_rev_xy: [8.8854, 18.0882, 33.4468]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [269.6864, 183.9016, 113.4312]
				want_rev_x: [266.1344, 136.2456, 50.3832]
				want_rev_y: [132.6912, 183.9016, 250.4264]
				want_rev_xy: [69.6432, 136.2456, 246.8744]
			}]
			trans: [// (2x2, 1x2, 2x1, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0]
				want_rev_x: [0.0, 0, 0]
				want_rev_y: [0.0, 0, 0]
				want_rev_xy: [0.0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [4.82, 1.82, 1.12]
				want_rev_x: [4.82, 1.82, 1.12]
				want_rev_y: [4.82, 1.82, 1.12]
				want_rev_xy: [4.82, 1.82, 1.12]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [15.8805, 8.9871, 6.2331]
				want_rev_x: [21.6264, 16.4664, 18.4311]
				want_rev_y: [6.2331, 8.9871, 15.8805]
				want_rev_xy: [18.4311, 16.4664, 21.6264]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [98.124, 60.9768, 43.1448]
				want_rev_x: [144.0912, 120.8112, 140.7288]
				want_rev_y: [20.9448, 60.9768, 120.324]
				want_rev_xy: [118.5288, 120.8112, 166.2912]
			}]
		},
		DgemvCase{ // 5x3
			m: 5
			n: 3
			a: [4.1, 6.2, 8.1, 9.6, 3.5, 9.1, 10, 7, 3, 1, 1, 2, 9, 2, 5]
			x: [1.0, 2, 3]
			y: [7.0, 8, 9, 10, 11]
			no_trans: [//(4x2, 4x1, 1x2, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0, 0, 0]
				want_rev_x: [0.0, 0, 0, 0, 0]
				want_rev_y: [0.0, 0, 0, 0, 0]
				want_rev_xy: [0.0, 0, 0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [7.0, 8, 9, 10, 11]
				want_rev_x: [7.0, 8, 9, 10, 11]
				want_rev_y: [7.0, 8, 9, 10, 11]
				want_rev_xy: [7.0, 8, 9, 10, 11]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [40.8, 43.9, 33, 9, 28]
				want_rev_x: [32.8, 44.9, 47, 7, 36]
				want_rev_y: [28.0, 9, 33, 43.9, 40.8]
				want_rev_xy: [36.0, 7, 47, 44.9, 32.8]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [284.4, 303.2, 210, 12, 158]
				want_rev_x: [220.4, 311.2, 322, -4, 222]
				want_rev_y: [182.0, 24, 210, 291.2, 260.4]
				want_rev_xy: [246.0, 8, 322, 299.2, 196.4]
			}]
			trans: [//( 2x4, 1x4, 2x1, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0]
				want_rev_x: [0.0, 0, 0]
				want_rev_y: [0.0, 0, 0]
				want_rev_xy: [0.0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [1.0, 2, 3]
				want_rev_x: [1.0, 2, 3]
				want_rev_y: [1.0, 2, 3]
				want_rev_xy: [1.0, 2, 3]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [304.5, 166.4, 231.5]
				want_rev_x: [302.1, 188.2, 258.1]
				want_rev_y: [231.5, 166.4, 304.5]
				want_rev_xy: [258.1, 188.2, 302.1]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [2430.0, 1319.2, 1834]
				want_rev_x: [2410.8, 1493.6, 2046.8]
				want_rev_y: [1846.0, 1319.2, 2418]
				want_rev_xy: [2058.8, 1493.6, 2398.8]
			}]
		},
		DgemvCase{ // 3x5
			m: 3
			n: 5
			a: [1.4, 2.34, 3.96, 0.96, 2.3, 3.43, 0.62, 1.09, 0.2, 3.56, 1.15, 0.58, 3.8, 1.16,
				0.01,
			]
			x: [2.34, 2.82, 4.73, 0.22, 3.91]
			y: [2.46, 2.22, 4.75]
			no_trans: [// (2x4, 2x1, 1x4, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0]
				want_rev_x: [0.0, 0, 0]
				want_rev_y: [0.0, 0, 0]
				want_rev_xy: [0.0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [2.46, 2.22, 4.75]
				want_rev_x: [2.46, 2.22, 4.75]
				want_rev_y: [2.46, 2.22, 4.75]
				want_rev_xy: [2.46, 2.22, 4.75]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [37.8098, 28.8939, 22.5949]
				want_rev_x: [32.8088, 27.5978, 25.8927]
				want_rev_y: [22.5949, 28.8939, 37.8098]
				want_rev_xy: [25.8927, 27.5978, 32.8088]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [287.7184, 217.8312, 152.2592]
				want_rev_x: [247.7104, 207.4624, 178.6416]
				want_rev_y: [165.9992, 217.8312, 273.9784]
				want_rev_xy: [192.3816, 207.4624, 233.9704]
			}]
			trans: [// (4x2, 1x2, 4x1, 1x1)
			DgemvSubcase{
				alpha: 0
				beta: 0
				want: [0.0, 0, 0, 0, 0]
				want_rev_x: [0.0, 0, 0, 0, 0]
				want_rev_y: [0.0, 0, 0, 0, 0]
				want_rev_xy: [0.0, 0, 0, 0, 0]
			}, DgemvSubcase{
				alpha: 0
				beta: 1
				want: [2.34, 2.82, 4.73, 0.22, 3.91]
				want_rev_x: [2.34, 2.82, 4.73, 0.22, 3.91]
				want_rev_y: [2.34, 2.82, 4.73, 0.22, 3.91]
				want_rev_xy: [2.34, 2.82, 4.73, 0.22, 3.91]
			}, DgemvSubcase{
				alpha: 1
				beta: 0
				want: [16.5211, 9.8878, 30.2114, 8.3156, 13.6087]
				want_rev_x: [17.0936, 13.9182, 30.5778, 7.8576, 18.8528]
				want_rev_y: [13.6087, 8.3156, 30.2114, 9.8878, 16.5211]
				want_rev_xy: [18.8528, 7.8576, 30.5778, 13.9182, 17.0936]
			}, DgemvSubcase{
				alpha: 8
				beta: -6
				want: [118.1288, 62.1824, 213.3112, 65.2048, 85.4096]
				want_rev_x: [122.7088, 94.4256, 216.2424, 61.5408, 127.3624]
				want_rev_y: [94.8296, 49.6048, 213.3112, 77.7824, 108.7088]
				want_rev_xy: [136.7824, 45.9408, 216.2424, 110.0256, 113.2888]
			}]
		},
		DgemvCase{ // 7x7 & math.nan() test
			m: 7
			n: 7
			a: [0.9, 2.6, 0.5, 1.8, 2.3, 0.6, 0.2, 1.6, 0.6, 1.3, 2.1, 1.4, 0.4, 0.8, 2.9, 0.9,
				2.3, 2.5, 1.4, 1.8, 1.6, 2.6, 2.8, 2.1, 0.3, math.nan(), 2.2, 1.3, 0.2, 2.2, 1.8,
				1.8, 2.1, 1.3, 1.4, 1.7, 1.4, 2.3, 2.0, 1.0, 0.0, 1.4, 2.1, 1.9, 0.8, 2.9, 1.3,
				0.3, 1.3]
			x: [0.4, 2.8, 3.5, 0.3, 0.6, 2.5, 3.1]
			y: [3.2, 4.4, 5.0, 4.3, 4.1, 1.4, 0.2]
			no_trans: [// (4x4, 4x2, 4x1, 2x4, 2x2, 2x1, 1x4, 1x2, 1x1)
				DgemvSubcase{
					alpha: 0
					beta: 0
					want: [0.0, 0, 0, math.nan(), 0, 0, 0]
					want_rev_x: [0.0, 0, 0, math.nan(), 0, 0, 0]
					want_rev_y: [0.0, 0, 0, math.nan(), 0, 0, 0]
					want_rev_xy: [0.0, 0, 0, math.nan(), 0, 0, 0]
				}, DgemvSubcase{
					alpha: 0
					beta: 1
					want: [3.2, 4.4, 5.0, math.nan(), 4.1, 1.4, 0.2]
					want_rev_x: [3.2, 4.4, 5.0, math.nan(), 4.1, 1.4, 0.2]
					want_rev_y: [3.2, 4.4, 5.0, math.nan(), 4.1, 1.4, 0.2]
					want_rev_xy: [3.2, 4.4, 5.0, math.nan(), 4.1, 1.4, 0.2]
				}, DgemvSubcase{
					alpha: 1
					beta: 0
					want: [13.43, 11.82, 22.78, math.nan(), 21.93, 18.19, 15.39]
					want_rev_x: [19.94, 14.21, 23.95, math.nan(), 19.29, 14.81, 18.52]
					want_rev_y: [15.39, 18.19, 21.93, math.nan(), 22.78, 11.82, 13.43]
					want_rev_xy: [18.52, 14.81, 19.29, math.nan(), 23.95, 14.21, 19.94]
				}, DgemvSubcase{
					alpha: 8
					beta: -6
					want: [88.24, 68.16, 152.24, math.nan(), 150.84, 137.12, 121.92]
					want_rev_x: [140.32, 87.28, 161.6, math.nan(), 129.72, 110.08, 146.96]
					want_rev_y: [103.92, 119.12, 145.44, math.nan(), 157.64, 86.16, 106.24]
					want_rev_xy: [128.96, 92.08, 124.32, math.nan(), 167.0, 105.28, 158.32]
				}]
			trans: [// (4x4, 2x4, 1x4, 4x2, 2x2, 1x2, 4x1, 2x1, 1x1)
				DgemvSubcase{
					alpha: 0
					beta: 0
					want: [0.0, 0, 0, 0, math.nan(), 0, 0]
					want_rev_x: [0.0, 0, 0, 0, math.nan(), 0, 0]
					want_rev_y: [0.0, 0, math.nan(), 0, 0, 0, 0]
					want_rev_xy: [0.0, 0, math.nan(), 0, 0, 0, 0]
				}, DgemvSubcase{
					alpha: 0
					beta: 1
					want: [0.4, 2.8, 3.5, 0.3, math.nan(), 2.5, 3.1]
					want_rev_x: [0.4, 2.8, 3.5, 0.3, math.nan(), 2.5, 3.1]
					want_rev_y: [0.4, 2.8, math.nan(), 0.3, 0.6, 2.5, 3.1]
					want_rev_xy: [0.4, 2.8, math.nan(), 0.3, 0.6, 2.5, 3.1]
				}, DgemvSubcase{
					alpha: 1
					beta: 0
					want: [39.22, 38.86, 38.61, 39.55, math.nan(), 27.53, 25.71]
					want_rev_x: [40.69, 40.33, 42.06, 41.92, math.nan(), 24.98, 30.63]
					want_rev_y: [25.71, 27.53, math.nan(), 39.55, 38.61, 38.86, 39.22]
					want_rev_xy: [30.63, 24.98, math.nan(), 41.92, 42.06, 40.33, 40.69]
				}, DgemvSubcase{
					alpha: 8
					beta: -6
					want: [311.36, 294.08, 287.88, 314.6, math.nan(), 205.24, 187.08]
					want_rev_x: [323.12, 305.84, 315.48, 333.56, math.nan(), 184.84, 226.44]
					want_rev_y: [203.28, 203.44, math.nan(), 314.6, 305.28, 295.88, 295.16]
					want_rev_xy: [242.64, 183.04, math.nan(), 333.56, 332.88, 307.64, 306.92]
				}]
		},
		DgemvCase{ // 11x11
			m: 11
			n: 11
			a: [0.4, 3.0, 2.5, 2.0, 0.4, 2.0, 2.0, 1.0, 0.1, 0.3, 2.0, 1.7, 0.7, 2.6, 1.6, 0.5,
				2.4, 3.0, 0.9, 0.1, 2.8, 1.3, 1.1, 2.2, 1.5, 0.8, 2.9, 0.4, 0.5, 1.7, 0.8, 2.6,
				0.7, 2.2, 1.7, 0.8, 2.9, 0.7, 0.7, 1.7, 1.8, 1.9, 2.4, 1.9, 0.3, 0.5, 1.6, 1.5,
				1.5, 2.4, 1.7, 1.2, 1.9, 2.8, 1.2, 1.4, 2.2, 1.7, 1.4, 2.7, 1.4, 0.9, 1.8, 0.5,
				1.2, 1.9, 0.8, 2.3, 1.7, 1.3, 2.0, 2.8, 2.6, 0.4, 2.5, 1.3, 0.5, 2.4, 2.8, 1.1,
				0.2, 0.4, 2.8, 0.5, 0.5, 0.0, 2.8, 1.9, 2.3, 1.8, 2.3, 1.7, 1.1, 0.1, 1.4, 1.2,
				1.9, 0.5, 0.6, 0.6, 2.4, 1.2, 0.3, 1.4, 1.3, 2.5, 2.6, 0.0, 1.3, 2.6, 0.7, 1.5,
				0.2, 1.4, 1.1, 1.8, 0.2, 1.0, 1.0, 0.6, 1.2]
			x: [2.5, 1.2, 0.8, 2.9, 3.4, 1.8, 4.6, 3.3, 3.8, 0.9, 1.1]
			y: [3.8, 3.4, 1.6, 4.8, 4.3, 0.5, 2.0, 2.5, 1.5, 2.8, 3.9]
			no_trans: [// (4x4, 4x2, 4x1, 2x4, 2x2, 2x1, 1x4, 1x2, 1x1)
				DgemvSubcase{
					alpha: 0
					beta: 0
					want: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_x: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_y: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_xy: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
				}, DgemvSubcase{
					alpha: 0
					beta: 1
					want: [3.8, 3.4, 1.6, 4.8, 4.3, 0.5, 2.0, 2.5, 1.5, 2.8, 3.9]
					want_rev_x: [3.8, 3.4, 1.6, 4.8, 4.3, 0.5, 2.0, 2.5, 1.5, 2.8, 3.9]
					want_rev_y: [3.8, 3.4, 1.6, 4.8, 4.3, 0.5, 2.0, 2.5, 1.5, 2.8, 3.9]
					want_rev_xy: [3.8, 3.4, 1.6, 4.8, 4.3, 0.5, 2.0, 2.5, 1.5, 2.8, 3.9]
				}, DgemvSubcase{
					alpha: 1
					beta: 0
					want: [32.71, 38.93, 33.55, 45.46, 39.24, 38.41, 46.23, 25.78, 37.33, 37.42,
						24.63,
					]
					want_rev_x: [39.82, 43.78, 37.73, 41.19, 40.17, 44.41, 42.75, 28.14, 35.6,
						41.25, 23.9]
					want_rev_y: [24.63, 37.42, 37.33, 25.78, 46.23, 38.41, 39.24, 45.46, 33.55,
						38.93, 32.71]
					want_rev_xy: [23.9, 41.25, 35.6, 28.14, 42.75, 44.41, 40.17, 41.19, 37.73,
						43.78, 39.82]
				}, DgemvSubcase{
					alpha: 8
					beta: -6
					want: [238.88, 291.04, 258.8, 334.88, 288.12, 304.28, 357.84, 191.24, 289.64,
						282.56, 173.64]
					want_rev_x: [295.76, 329.84, 292.24, 300.72, 295.56, 352.28, 330.0, 210.12,
						275.8, 313.2, 167.8]
					want_rev_y: [174.24, 278.96, 289.04, 177.44, 344.04, 304.28, 301.92, 348.68,
						259.4, 294.64, 238.28]
					want_rev_xy: [168.4, 309.6, 275.2, 196.32, 316.2, 352.28, 309.36, 314.52, 292.84,
						333.44, 295.16]
				}]
			trans: [// (4x4, 2x4, 1x4, 4x2, 2x2, 1x2, 4x1, 2x1, 1x1)
				DgemvSubcase{
					alpha: 0
					beta: 0
					want: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_x: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_y: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					want_rev_xy: [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
				}, DgemvSubcase{
					alpha: 0
					beta: 1
					want: [2.5, 1.2, 0.8, 2.9, 3.4, 1.8, 4.6, 3.3, 3.8, 0.9, 1.1]
					want_rev_x: [2.5, 1.2, 0.8, 2.9, 3.4, 1.8, 4.6, 3.3, 3.8, 0.9, 1.1]
					want_rev_y: [2.5, 1.2, 0.8, 2.9, 3.4, 1.8, 4.6, 3.3, 3.8, 0.9, 1.1]
					want_rev_xy: [2.5, 1.2, 0.8, 2.9, 3.4, 1.8, 4.6, 3.3, 3.8, 0.9, 1.1]
				}, DgemvSubcase{
					alpha: 1
					beta: 0
					want: [37.07, 55.58, 46.05, 47.34, 33.88, 54.19, 50.85, 39.31, 31.29, 55.31,
						46.98,
					]
					want_rev_x: [38.11, 63.38, 46.44, 40.04, 34.63, 59.27, 50.13, 35.45, 28.26,
						51.64, 46.22]
					want_rev_y: [46.98, 55.31, 31.29, 39.31, 50.85, 54.19, 33.88, 47.34, 46.05,
						55.58, 37.07]
					want_rev_xy: [46.22, 51.64, 28.26, 35.45, 50.13, 59.27, 34.63, 40.04, 46.44,
						63.38, 38.11]
				}, DgemvSubcase{
					alpha: 8
					beta: -6
					want: [281.56, 437.44, 363.6, 361.32, 250.64, 422.72, 379.2, 294.68, 227.52,
						437.08, 369.24]
					want_rev_x: [289.88, 499.84, 366.72, 302.92, 256.64, 463.36, 373.44, 263.8,
						203.28, 407.72, 363.16]
					want_rev_y: [360.84, 435.28, 245.52, 297.08, 386.4, 422.72, 243.44, 358.92,
						345.6, 439.24, 289.96]
					want_rev_xy: [354.76, 405.92, 221.28, 266.2, 380.64, 463.36, 249.44, 300.52,
						348.72, 501.64, 298.28]
				}]
		},
	]
)

struct DgemvCase {
	m        int
	n        int
	a        []f64
	no_trans []DgemvSubcase
	trans    []DgemvSubcase
mut:
	x []f64
	y []f64
}

struct DgemvSubcase {
	alpha       f64
	beta        f64
	want        []f64
	want_rev_x  []f64
	want_rev_y  []f64
	want_rev_xy []f64
}

fn test_gemv() {
	for mut test in float64.dgemv_tests {
		for case in test.no_trans {
			dgemvcomp(mut test, false, case)
		}

		for case in test.trans {
			dgemvcomp(mut test, true, case)
		}
	}
}

fn dgemvcomp(mut test DgemvCase, trans bool, case DgemvSubcase) {
	tol := 1e-15
	x_gd_val, y_gd_val, a_gd_val := 0.5, 1.5, 10
	gd_ln := 4

	test_x := if trans { test.y } else { test.x }
	test_y := if trans { test.x } else { test.y }

	mut xg, mut yg := guard_vector(test_x, x_gd_val, gd_ln), guard_vector(test_y, y_gd_val,
		gd_ln)
	mut x, mut y := xg[gd_ln..xg.len - gd_ln], yg[gd_ln..yg.len - gd_ln]
	mut ag := guard_vector(test.a, a_gd_val, gd_ln)
	mut a := ag[gd_ln..ag.len - gd_ln]

	lda := u32(test.n)

	if trans {
		gemv_t(u32(test.m), u32(test.n), case.alpha, a, lda, x, 1, case.beta, mut y, 1)
	} else {
		gemv_n(u32(test.m), u32(test.n), case.alpha, a, lda, x, 1, case.beta, mut y, 1)
	}

	for i, w in case.want {
		assert tolerance(y[i], w, tol)
	}

	assert is_valid_guard(xg, x_gd_val, gd_ln)
	assert is_valid_guard(yg, y_gd_val, gd_ln)
	assert is_valid_guard(ag, a_gd_val, gd_ln)
	assert equal_strided(test_x, x, 1)
	assert equal_strided(test.a, a, 1)

	for j, inc in new_inc_set(-1, 1, 2, 3, 90) {
		mut want, mut incy := case.want, inc.y
		if inc.x < 0 && inc.y < 0 {
			want = case.want_rev_xy
			incy = -inc.y
		} else if inc.x < 0 {
			want = case.want_rev_x
		} else if inc.y < 0 {
			want = case.want_rev_y
			incy = -inc.y
		}

		xg, yg = guard_inc_vector(test_x, x_gd_val, inc.x, gd_ln), guard_inc_vector(test_y,
			y_gd_val, inc.y, gd_ln)
		x, y = xg[gd_ln..xg.len - gd_ln], yg[gd_ln..yg.len - gd_ln]
		ag = guard_vector(test.a, a_gd_val, gd_ln)
		a = ag[gd_ln..ag.len - gd_ln]

		if trans {
			gemv_t(u32(test.m), u32(test.n), case.alpha, a, lda, x, u32(inc.x), case.beta, mut
				y, u32(inc.y))
		} else {
			gemv_n(u32(test.m), u32(test.n), case.alpha, a, lda, x, u32(inc.x), case.beta, mut
				y, u32(inc.y))
		}

		for i, w in want {
			assert tolerance(y[i * incy], w, tol)
		}

		assert is_valid_inc_guard(xg, x_gd_val, inc.x, gd_ln)
		assert is_valid_inc_guard(yg, y_gd_val, inc.y, gd_ln)
		assert is_valid_guard(ag, a_gd_val, gd_ln)
		assert equal_strided(test_x, x, inc.x)
		assert equal_strided(test.a, a, 1)
	}
}
