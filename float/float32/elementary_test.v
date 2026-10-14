module float32

import math

// Reference pairs [input_bits, correctly_rounded_output_bits] generated with
// mpmath at 200 bits of precision. The double-double implementations must
// reproduce the output bit for bit.
const exp_references = [
	[u32(1090901509), u32(1166420054)],
	[u32(3239924247), u32(945889881)],
	[u32(1087178662), u32(1142393799)],
	[u32(1089491545), u32(1155811810)],
	[u32(3239960094), u32(945394006)],
	[u32(1094773885), u32(1210606351)],
	[u32(3240882658), u32(934577322)],
	[u32(1079349026), u32(1105267623)],
	[u32(1095057585), u32(1214034995)],
	[u32(3239341512), u32(952384242)],
]

const log_references = [
	// Regression: exact log of this input is 8.2e-17 below the f32
	// midpoint, so f64 evaluation double-rounds to ...e8 while the
	// correctly rounded result is ...e7 (found exhaustively, #65).
	[u32(0x41178feb), u32(0x400fe5e7)],
	[u32(1110602972), u32(1081283394)],
	[u32(1111748638), u32(1081675366)],
	[u32(1109670940), u32(1080935067)],
	[u32(1112298260), u32(1081851155)],
	[u32(1109032535), u32(1080678606)],
	[u32(1102651084), u32(1078529892)],
	[u32(1079409042), u32(1067109032)],
	[u32(1097861327), u32(1076712203)],
	[u32(1102824160), u32(1078589305)],
	[u32(1114192292), u32(1082268236)],
]

const sin_references = [
	[u32(3183907622), u32(3183887240)],
	[u32(3234109993), u32(1041121293)],
	[u32(3214594143), u32(3211753621)],
	[u32(3218720751), u32(3212693950)],
	[u32(3212931179), u32(3210278211)],
	[u32(1078303375), u32(1029519191)],
	[u32(3228052758), u32(1055865148)],
	[u32(3222692782), u32(3207998147)],
	[u32(1066854655), u32(1064081823)],
	[u32(3238086658), u32(3212409858)],
]

const cos_references = [
	[u32(3218644086), u32(3187158318)],
	[u32(1083261198), u32(3190847512)],
	[u32(1090502317), u32(3188517028)],
	[u32(3234929276), u32(1064826253)],
	[u32(1068006205), u32(1048636257)],
	[u32(1074962194), u32(3207124337)],
	[u32(1081270152), u32(3209382133)],
	[u32(1090762417), u32(3200058485)],
	[u32(3227099926), u32(3212277345)],
	[u32(3233645187), u32(1064271803)],
]

fn test_exp_matches_correctly_rounded_references() {
	for pair in exp_references {
		got := exp(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'exp bits mismatch for input ${pair[0]}'
	}
}

fn test_log_matches_correctly_rounded_references() {
	for pair in log_references {
		got := log(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log bits mismatch for input ${pair[0]}'
	}
}

fn test_sin_matches_correctly_rounded_references() {
	for pair in sin_references {
		got := sin(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'sin bits mismatch for input ${pair[0]}'
	}
}

fn test_cos_matches_correctly_rounded_references() {
	for pair in cos_references {
		got := cos(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'cos bits mismatch for input ${pair[0]}'
	}
}

fn test_elementary_special_values() {
	assert exp(0.0) == 1.0
	assert log(1.0) == 0.0
	assert sin(0.0) == 0.0
	assert cos(0.0) == 1.0
	assert math.is_inf(f64(exp(100.0)), 1)
	assert log(0.0) < -3.4e38 // -inf
}

fn test_more_elementary_matches_correctly_rounded_references() {
	for pair in tan_references {
		got := tan(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'tan bits mismatch for input ${pair[0]}'
	}
	for pair in exp2_references {
		got := exp2(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'exp2 bits mismatch for input ${pair[0]}'
	}
	for pair in expm1_references {
		got := expm1(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'expm1 bits mismatch for input ${pair[0]}'
	}
	for pair in log2_references {
		got := log2(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log2 bits mismatch for input ${pair[0]}'
	}
	for pair in log10_references {
		got := log10(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log10 bits mismatch for input ${pair[0]}'
	}
	for pair in log1p_references {
		got := log1p(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'log1p bits mismatch for input ${pair[0]}'
	}
	for pair in asin_references {
		got := asin(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'asin bits mismatch for input ${pair[0]}'
	}
	for pair in acos_references {
		got := acos(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'acos bits mismatch for input ${pair[0]}'
	}
	for pair in atan_references {
		got := atan(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'atan bits mismatch for input ${pair[0]}'
	}
	for pair in sinh_references {
		got := sinh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'sinh bits mismatch for input ${pair[0]}'
	}
	for pair in cosh_references {
		got := cosh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'cosh bits mismatch for input ${pair[0]}'
	}
	for pair in tanh_references {
		got := tanh(math.f32_from_bits(pair[0]))
		assert math.f32_bits(got) == pair[1], 'tanh bits mismatch for input ${pair[0]}'
	}
}

fn test_more_elementary_special_values() {
	assert exp2(10.0) == 1024.0
	assert expm1(0.0) == 0.0
	assert log2(1024.0) == 10.0
	assert log10(1000.0) == 3.0
	assert log1p(0.0) == 0.0
	assert asin(0.0) == 0.0
	assert acos(1.0) == 0.0
	assert atan(0.0) == 0.0
	assert sinh(0.0) == 0.0
	assert cosh(0.0) == 1.0
	assert tanh(0.0) == 0.0
	assert math.abs(f64(tan(0.7853981633974483)) - 1.0) < 1e-6
}
const tan_references = [
	[u32(1100703705), u32(1059475839)],
	[u32(3240812450), u32(3225666232)],
	[u32(1087914897), u32(1057205381)],
	[u32(1047947489), u32(1048266578)],
	[u32(1051162628), u32(1051571536)],
	[u32(3247033728), u32(3247808207)],
	[u32(1086303947), u32(3197797435)],
	[u32(1097277631), u32(3226006430)],
	[u32(3244678887), u32(1082708519)],
	[u32(3246591345), u32(3209450055)],
]

const exp2_references = [
	[u32(1117874151), u32(1741708326)],
	[u32(3258521606), u32(676580372)],
	[u32(3267712281), u32(237064772)],
	[u32(1116013071), u32(1622509127)],
	[u32(3266709493), u32(301810130)],
	[u32(1099879241), u32(1214724642)],
	[u32(1121798278), u32(1992798635)],
	[u32(1118797364), u32(1800847127)],
	[u32(3263560487), u32(503371714)],
	[u32(3257866254), u32(697680531)],
]

const expm1_references = [
	[u32(1006715514), u32(1006749018)],
	[u32(1103396507), u32(1361908225)],
	[u32(996201397), u32(996226700)],
	[u32(3156348783), u32(3156296429)],
	[u32(1108377346), u32(1502262927)],
	[u32(3139515066), u32(3139502084)],
	[u32(3258642146), u32(3212836864)],
	[u32(3155684840), u32(3155638817)],
	[u32(1113219706), u32(1725537524)],
	[u32(3262595755), u32(3212836864)],
]

const log2_references = [
	[u32(1722674088), u32(1117577843)],
	[u32(1263238667), u32(1102928324)],
	[u32(1151324686), u32(1092952060)],
	[u32(1015649586), u32(3233589953)],
	[u32(806924131), u32(3254122229)],
	[u32(767423578), u32(3255679186)],
	[u32(1340380738), u32(1107515565)],
	[u32(807042585), u32(3254113328)],
	[u32(1637789437), u32(1116249785)],
	[u32(1599375695), u32(1115614496)],
]

const log10_references = [
	[u32(663437485), u32(3244727045)],
	[u32(948764123), u32(3229975706)],
	[u32(724861249), u32(3242399316)],
	[u32(1608261897), u32(1100743383)],
	[u32(1855660457), u32(1105398496)],
	[u32(1365158068), u32(1093430390)],
	[u32(1062045759), u32(3183692836)],
	[u32(1261989653), u32(1088594527)],
	[u32(394347332), u32(3250626566)],
	[u32(1163987046), u32(1080269695)],
]

const log1p_references = [
	[u32(967414088), u32(967412291)],
	[u32(1150194691), u32(1088506211)],
	[u32(1075677983), u32(1067381041)],
	[u32(1076752315), u32(1067979861)],
	[u32(1087747140), u32(1073902853)],
	[u32(1082792435), u32(1070979108)],
	[u32(1047644470), u32(1046024302)],
	[u32(851218058), u32(851218058)],
	[u32(972059335), u32(972055723)],
	[u32(939669729), u32(939669597)],
]

const asin_references = [
	[u32(1053168551), u32(1053516334)],
	[u32(3211512187), u32(3214269222)],
	[u32(1058649065), u32(1059380578)],
	[u32(3211820802), u32(3214690635)],
	[u32(1057279791), u32(1057726809)],
	[u32(3209307518), u32(3211330492)],
	[u32(1050136458), u32(1050288326)],
	[u32(3187276291), u32(3187317245)],
	[u32(1028705797), u32(1028711731)],
	[u32(3203792371), u32(3204467907)],
]

const acos_references = [
	[u32(3208707522), u32(1075523279)],
	[u32(1052731628), u32(1066927276)],
	[u32(1060962644), u32(1060995296)],
	[u32(3187680457), u32(1071193915)],
	[u32(1058416038), u32(1064414544)],
	[u32(1064280403), u32(1052251878)],
	[u32(1045457746), u32(1068422019)],
	[u32(1052073020), u32(1067104063)],
	[u32(1043379944), u32(1068686474)],
	[u32(3191341913), u32(1071657071)],
]

const atan_references = [
	[u32(1051291759), u32(1050911098)],
	[u32(1095430335), u32(1069481403)],
	[u32(1119751377), u32(1070053128)],
	[u32(3267292817), u32(3217537184)],
	[u32(3258282892), u32(3217440158)],
	[u32(3266311931), u32(3217529711)],
	[u32(1100226764), u32(1069688796)],
	[u32(3261863711), u32(3217482939)],
	[u32(1095492087), u32(1069484440)],
	[u32(3266893865), u32(3217534290)],
]

const sinh_references = [
	[u32(3264200112), u32(4073593141)],
	[u32(3252945639), u32(3549101525)],
	[u32(1111241225), u32(1626020568)],
	[u32(3236491704), u32(3291826354)],
	[u32(3254176232), u32(3577063724)],
	[u32(1090617104), u32(1154257684)],
	[u32(3261318122), u32(3893226562)],
	[u32(1114479771), u32(1775238035)],
	[u32(3264505029), u32(4102285364)],
	[u32(1108789242), u32(1512498542)],
]

const cosh_references = [
	[u32(1103611199), u32(1359106970)],
	[u32(3240772958), u32(1185119666)],
	[u32(1106229993), u32(1419139485)],
	[u32(3264835660), u32(1984786814)],
	[u32(1107518894), u32(1453844519)],
	[u32(3261410534), u32(1749674038)],
	[u32(3246730673), u32(1258390585)],
	[u32(3250785176), u32(1351640231)],
	[u32(3264360296), u32(1940841539)],
	[u32(3256361484), u32(1516896414)],
]

const tanh_references = [
	[u32(1092652407), u32(1065353216)],
	[u32(1100007314), u32(1065353216)],
	[u32(3220098687), u32(3212051700)],
	[u32(1095636911), u32(1065353216)],
	[u32(3224262910), u32(3212693087)],
	[u32(3238960282), u32(3212836863)],
	[u32(1100431261), u32(1065353216)],
	[u32(3240288146), u32(3212836864)],
	[u32(1095194936), u32(1065353216)],
	[u32(3247408286), u32(3212836864)],
]

