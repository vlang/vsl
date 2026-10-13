module float32

import math

// Hard cases for the table-maker's dilemma, found by directed search:
// sample an f32 output y, take the exact midpoint between y and the next
// f32, invert the function at ~200 bits, and evaluate the f32 inputs
// nearest to that inverse. Those inputs produce the exact results closest
// to an f32 midpoint, where evaluating in f64 and rounding once is most
// likely to double-round incorrectly.
//
// Over 1,573,854 such directed candidates covering all sixteen functions
// in elementary.v, the f64 evaluation never disagreed with the 200-bit
// correctly rounded result. The closest approach to a midpoint was
// ~1.3e-07 f32 ulps (log/log2), still dozens of f64 ulps away, while the
// f64 evaluation error is ~1 f64 ulp. This is strong evidence, not a
// proof for all inputs; the proof remains the open part of vlang/vsl#65.
// The ten hardest inputs per function are pinned below as bit-exact
// regression tests.

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


fn test_expm1_hard_cases() {
	for pair in expm1_hard_references {
		got := expm1(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'expm1 hard bits mismatch for input ${pair[0]}'
	}
}

fn test_log1p_hard_cases() {
	for pair in log1p_hard_references {
		got := log1p(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log1p hard bits mismatch for input ${pair[0]}'
	}
}

fn test_log10_hard_cases() {
	for pair in log10_hard_references {
		got := log10(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log10 hard bits mismatch for input ${pair[0]}'
	}
}

fn test_asin_hard_cases() {
	for pair in asin_hard_references {
		got := asin(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'asin hard bits mismatch for input ${pair[0]}'
	}
}

fn test_acos_hard_cases() {
	for pair in acos_hard_references {
		got := acos(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'acos hard bits mismatch for input ${pair[0]}'
	}
}

fn test_atan_hard_cases() {
	for pair in atan_hard_references {
		got := atan(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'atan hard bits mismatch for input ${pair[0]}'
	}
}

fn test_sinh_hard_cases() {
	for pair in sinh_hard_references {
		got := sinh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'sinh hard bits mismatch for input ${pair[0]}'
	}
}

fn test_cosh_hard_cases() {
	for pair in cosh_hard_references {
		got := cosh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'cosh hard bits mismatch for input ${pair[0]}'
	}
}

fn test_tanh_hard_cases() {
	for pair in tanh_hard_references {
		got := tanh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'tanh hard bits mismatch for input ${pair[0]}'
	}
}

const expm1_hard_references = [
	[u32(931613376), u32(931613448)], // dist 8.42e-05 ulp
	[u32(1051085689), u32(1053063782)], // dist 4.30e-04 ulp
	[u32(960649916), u32(960651096)], // dist 6.62e-04 ulp
	[u32(867493200), u32(867493200)], // dist 6.82e-04 ulp
	[u32(905164397), u32(905164412)], // dist 9.44e-04 ulp
	[u32(945213238), u32(945213598)], // dist 9.87e-04 ulp
	[u32(1093696793), u32(1198596607)], // dist 1.03e-03 ulp
	[u32(909258050), u32(909258066)], // dist 1.46e-03 ulp
	[u32(966201757), u32(966203183)], // dist 1.56e-03 ulp
	[u32(948351704), u32(948351988)], // dist 1.62e-03 ulp
]

const log1p_hard_references = [
	[u32(1270613027), u32(1099442438)], // dist 1.95e-07 ulp
	[u32(1354481177), u32(1103075761)], // dist 1.10e-06 ulp
	[u32(1418415143), u32(1105826553)], // dist 5.30e-06 ulp
	[u32(1154423034), u32(1089288505)], // dist 5.89e-06 ulp
	[u32(1265773449), u32(1099211732)], // dist 1.11e-05 ulp
	[u32(1367270893), u32(1103599494)], // dist 1.36e-05 ulp
	[u32(1175168739), u32(1091670531)], // dist 1.65e-05 ulp
	[u32(1423252453), u32(1106049476)], // dist 1.88e-05 ulp
	[u32(1395759316), u32(1104863679)], // dist 2.51e-05 ulp
	[u32(1350648840), u32(1102880096)], // dist 2.61e-05 ulp
]

const log10_hard_references = [
	[u32(323214074), u32(3251952389)], // dist 5.19e-07 ulp
	[u32(802100047), u32(3239495904)], // dist 7.74e-07 ulp
	[u32(1305068360), u32(1091175942)], // dist 1.42e-06 ulp
	[u32(1837545926), u32(1105050731)], // dist 2.00e-06 ulp
	[u32(1767619520), u32(1103741676)], // dist 2.52e-06 ulp
	[u32(1524563709), u32(1099168065)], // dist 2.54e-06 ulp
	[u32(1689787213), u32(1102280959)], // dist 3.97e-06 ulp
	[u32(394074065), u32(3250631401)], // dist 4.56e-06 ulp
	[u32(1872575720), u32(1105717220)], // dist 5.20e-06 ulp
	[u32(757845897), u32(3241159185)], // dist 5.77e-06 ulp
]

const asin_hard_references = [
	[u32(1045325809), u32(1045419126)], // dist 2.01e-05 ulp
	[u32(1062394023), u32(1064812348)], // dist 1.89e-04 ulp
	[u32(1064743907), u32(1067873695)], // dist 2.00e-04 ulp
	[u32(1040400110), u32(1040423835)], // dist 2.09e-04 ulp
	[u32(1056045703), u32(1056704734)], // dist 2.36e-04 ulp
	[u32(1064128485), u32(1066916302)], // dist 2.66e-04 ulp
	[u32(1041582778), u32(1041617775)], // dist 2.91e-04 ulp
	[u32(1053987533), u32(1054409564)], // dist 4.63e-04 ulp
	[u32(1038860027), u32(1038894352)], // dist 4.83e-04 ulp
	[u32(1062600981), u32(1065183244)], // dist 5.11e-04 ulp
]

const acos_hard_references = [
	[u32(976945424), u32(1070135419)], // dist 2.24e-06 ulp
	[u32(998347276), u32(1070108233)], // dist 8.18e-06 ulp
	[u32(1057826376), u32(1065131696)], // dist 9.02e-06 ulp
	[u32(941691153), u32(1070141080)], // dist 9.09e-06 ulp
	[u32(1015915322), u32(1069996358)], // dist 9.33e-06 ulp
	[u32(1000624629), u32(1070099336)], // dist 1.46e-05 ulp
	[u32(958129220), u32(1070140156)], // dist 1.69e-05 ulp
	[u32(1012921160), u32(1070026736)], // dist 1.78e-05 ulp
	[u32(1002208734), u32(1070093149)], // dist 1.83e-05 ulp
	[u32(941691152), u32(1070141081)], // dist 2.14e-05 ulp
]

const atan_hard_references = [
	[u32(1066872905), u32(1063143071)], // dist 3.78e-06 ulp
	[u32(1088576054), u32(1068963291)], // dist 8.94e-06 ulp
	[u32(1076356303), u32(1067086360)], // dist 1.21e-05 ulp
	[u32(1077998526), u32(1067454787)], // dist 1.67e-05 ulp
	[u32(1067767306), u32(1063852188)], // dist 1.88e-05 ulp
	[u32(1080680723), u32(1067900751)], // dist 2.33e-05 ulp
	[u32(1084729276), u32(1068559315)], // dist 2.41e-05 ulp
	[u32(1058179167), u32(1057298023)], // dist 3.08e-05 ulp
	[u32(1067729868), u32(1063823961)], // dist 3.89e-05 ulp
	[u32(1094223160), u32(1069415831)], // dist 4.17e-05 ulp
]

const sinh_hard_references = [
	[u32(1061612460), u32(1062964499)], // dist 3.02e-04 ulp
	[u32(971540113), u32(971540113)], // dist 4.24e-04 ulp
	[u32(1069652250), u32(1074407944)], // dist 4.73e-04 ulp
	[u32(1102910576), u32(1342767323)], // dist 6.90e-04 ulp
	[u32(1098096551), u32(1241136442)], // dist 7.55e-04 ulp
	[u32(1040222665), u32(1040244804)], // dist 9.41e-04 ulp
	[u32(971532235), u32(971532235)], // dist 1.20e-03 ulp
	[u32(1069501136), u32(1074229641)], // dist 1.36e-03 ulp
	[u32(1025635028), u32(1025637794)], // dist 1.52e-03 ulp
	[u32(993175462), u32(993175477)], // dist 1.52e-03 ulp
]

const cosh_hard_references = [
	[u32(1095025037), u32(1205204317)], // dist 1.10e-04 ulp
	[u32(1098672604), u32(1247328774)], // dist 2.55e-04 ulp
	[u32(1046268146), u32(1065548956)], // dist 3.39e-04 ulp
	[u32(1027015986), u32(1065361592)], // dist 3.86e-04 ulp
	[u32(1083611763), u32(1113411683)], // dist 4.05e-04 ulp
	[u32(1083528564), u32(1112847632)], // dist 4.67e-04 ulp
	[u32(1105202652), u32(1395229310)], // dist 5.15e-04 ulp
	[u32(1034880072), u32(1065383865)], // dist 5.74e-04 ulp
	[u32(1087640412), u32(1136451400)], // dist 5.91e-04 ulp
	[u32(1039761175), u32(1065415542)], // dist 8.20e-04 ulp
]

const tanh_hard_references = [
	[u32(1068469265), u32(1063323591)], // dist 4.66e-06 ulp
	[u32(1064484970), u32(1060974179)], // dist 7.56e-06 ulp
	[u32(1071209062), u32(1064265508)], // dist 7.67e-06 ulp
	[u32(1069608523), u32(1063783771)], // dist 2.12e-05 ulp
	[u32(1062500040), u32(1059991929)], // dist 2.84e-05 ulp
	[u32(1061853910), u32(1059635803)], // dist 3.60e-05 ulp
	[u32(1074039662), u32(1064828352)], // dist 5.55e-05 ulp
	[u32(1078102191), u32(1065276551)], // dist 6.44e-05 ulp
	[u32(1030039987), u32(1030024336)], // dist 7.22e-05 ulp
	[u32(1065561435), u32(1061525043)], // dist 9.11e-05 ulp
]
