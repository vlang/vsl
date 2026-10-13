module float32

import math

// Hard cases for the table-maker's dilemma, found by directed search:
// sample an f32 output y, take the exact midpoint between y and the next
// f32, invert the function at ~200 bits, and evaluate the f32 inputs
// nearest to that inverse. Those inputs produce the exact results closest
// to an f32 midpoint, where evaluating in f64 and rounding once is most
// likely to double-round incorrectly.
//
// Over 749,625 such directed candidates (exp, exp2, log, log2, sin, cos,
// tan) the f64 evaluation never disagreed with the 200-bit correctly
// rounded result. The closest approach to a midpoint was 7.1e-08 f32 ulps
// (log), still about 38 f64 ulps away, while the f64 evaluation error is
// ~1 f64 ulp. This is strong evidence, not a proof for all inputs; the
// proof remains the open part of vlang/vsl#65. The ten hardest inputs per
// function are pinned below as bit-exact regression tests.

fn test_exp_hard_cases() {
	for pair in exp_hard_references {
		got := exp(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'exp hard bits mismatch for input ${pair[0]}'
	}
}

fn test_exp2_hard_cases() {
	for pair in exp2_hard_references {
		got := exp2(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'exp2 hard bits mismatch for input ${pair[0]}'
	}
}

fn test_log_hard_cases() {
	for pair in log_hard_references {
		got := log(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log hard bits mismatch for input ${pair[0]}'
	}
}

fn test_log2_hard_cases() {
	for pair in log2_hard_references {
		got := log2(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log2 hard bits mismatch for input ${pair[0]}'
	}
}

fn test_sin_hard_cases() {
	for pair in sin_hard_references {
		got := sin(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'sin hard bits mismatch for input ${pair[0]}'
	}
}

fn test_cos_hard_cases() {
	for pair in cos_hard_references {
		got := cos(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'cos hard bits mismatch for input ${pair[0]}'
	}
}

fn test_tan_hard_cases() {
	for pair in tan_hard_references {
		got := tan(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'tan hard bits mismatch for input ${pair[0]}'
	}
}const exp_hard_references = [
	[u32(1098298036), u32(1251450986)], // dist 2.23e-04 ulp
	[u32(982897682), u32(1065362811)], // dist 2.70e-04 ulp
	[u32(1046496415), u32(1067407133)], // dist 4.73e-04 ulp
	[u32(1021523326), u32(1065589135)], // dist 4.74e-04 ulp
	[u32(982897681), u32(1065362810)], // dist 7.08e-04 ulp
	[u32(1010538816), u32(1065449818)], // dist 7.09e-04 ulp
	[u32(1079709462), u32(1106591089)], // dist 7.81e-04 ulp
	[u32(1115970518), u32(1865555147)], // dist 8.43e-04 ulp
	[u32(1017915398), u32(1065531370)], // dist 9.93e-04 ulp
	[u32(982897683), u32(1065362811)], // dist 1.25e-03 ulp
]
const exp2_hard_references = [
	[u32(1066466221), u32(1074549889)], // dist 3.27e-04 ulp
	[u32(1008438497), u32(1065408601)], // dist 5.12e-04 ulp
	[u32(1050345991), u32(1067311899)], // dist 5.22e-04 ulp
	[u32(1007754614), u32(1065404874)], // dist 8.12e-04 ulp
	[u32(1041601799), u32(1066247072)], // dist 1.11e-03 ulp
	[u32(1118852029), u32(1804557696)], // dist 1.25e-03 ulp
	[u32(1036817498), u32(1065954625)], // dist 1.28e-03 ulp
	[u32(1006925182), u32(1065400356)], // dist 1.31e-03 ulp
	[u32(1116747999), u32(1670004363)], // dist 1.48e-03 ulp
	[u32(1024569078), u32(1065562593)], // dist 1.48e-03 ulp
]
const log_hard_references = [
	[u32(845339837), u32(3247514667)], // dist 7.10e-08 ulp
	[u32(1134088508), u32(1085742547)], // dist 4.23e-07 ulp
	[u32(446088050), u32(3259794511)], // dist 7.11e-07 ulp
	[u32(1694652443), u32(1112540233)], // dist 1.37e-06 ulp
	[u32(117370471), u32(3265046749)], // dist 1.65e-06 ulp
	[u32(1498192890), u32(1108297535)], // dist 2.11e-06 ulp
	[u32(246983252), u32(3263635378)], // dist 2.43e-06 ulp
	[u32(775469742), u32(3250529653)], // dist 2.59e-06 ulp
	[u32(1353985563), u32(1103054205)], // dist 3.49e-06 ulp
	[u32(1645389899), u32(1111480920)], // dist 3.72e-06 ulp
]
const log2_hard_references = [
	[u32(784369267), u32(3255149815)], // dist 1.88e-07 ulp
	[u32(536874850), u32(3262906191)], // dist 1.62e-06 ulp
	[u32(647677664), u32(3259426656)], // dist 2.42e-06 ulp
	[u32(1331173279), u32(1107168069)], // dist 2.45e-06 ulp
	[u32(1508351066), u32(1112763415)], // dist 2.95e-06 ulp
	[u32(418830744), u32(3264879330)], // dist 3.80e-06 ulp
	[u32(331615506), u32(3266233619)], // dist 4.11e-06 ulp
	[u32(312524322), u32(3266533313)], // dist 4.58e-06 ulp
	[u32(1836442908), u32(1119347264)], // dist 5.23e-06 ulp
	[u32(555048731), u32(3262323685)], // dist 5.90e-06 ulp
]
const sin_hard_references = [
	[u32(1064807282), u32(1062391149)], // dist 2.29e-05 ulp
	[u32(1045765073), u32(1045664475)], // dist 3.02e-05 ulp
	[u32(1058575595), u32(1057993976)], // dist 5.13e-05 ulp
	[u32(1061343831), u32(1060146607)], // dist 5.22e-05 ulp
	[u32(1063578359), u32(1061657445)], // dist 8.60e-05 ulp
	[u32(1065782646), u32(1063138888)], // dist 8.97e-05 ulp
	[u32(1056939912), u32(1056252567)], // dist 9.68e-05 ulp
	[u32(1056634545), u32(1055983813)], // dist 1.01e-04 ulp
	[u32(1052120754), u32(1051870783)], // dist 1.05e-04 ulp
	[u32(1052047827), u32(1051802391)], // dist 1.57e-04 ulp
]
const cos_hard_references = [
	[u32(1074348871), u32(3205168682)], // dist 8.10e-06 ulp
	[u32(1048285448), u32(1064849472)], // dist 1.71e-05 ulp
	[u32(1025836931), u32(1065339601)], // dist 3.38e-05 ulp
	[u32(1009577396), u32(1065352282)], // dist 5.87e-05 ulp
	[u32(1022469397), u32(1065345917)], // dist 6.08e-05 ulp
	[u32(1047450334), u32(1064898986)], // dist 6.63e-05 ulp
	[u32(1049539848), u32(1064705734)], // dist 7.03e-05 ulp
	[u32(1024604462), u32(1065342527)], // dist 8.28e-05 ulp
	[u32(1015795932), u32(1065350773)], // dist 8.45e-05 ulp
	[u32(1050642041), u32(1064545437)], // dist 9.68e-05 ulp
]
const tan_hard_references = [
	[u32(1069540693), u32(1096748230)], // dist 3.29e-05 ulp
	[u32(1069770668), u32(1102374373)], // dist 8.21e-05 ulp
	[u32(1068563552), u32(1084759487)], // dist 3.10e-04 ulp
	[u32(1069729858), u32(1101197147)], // dist 3.62e-04 ulp
	[u32(1069482126), u32(1095444987)], // dist 6.92e-04 ulp
	[u32(1068532119), u32(1084539075)], // dist 7.73e-04 ulp
	[u32(1069395747), u32(1093895802)], // dist 8.37e-04 ulp
	[u32(1049473814), u32(1049718406)], // dist 1.12e-03 ulp
	[u32(1066504213), u32(1074412787)], // dist 1.42e-03 ulp
	[u32(1056579225), u32(1057492784)], // dist 1.50e-03 ulp
]
