module float32

import math

// Reference pairs [input_bits, correctly_rounded_output_bits] generated with
// mpmath at 200 bits of precision. The f64-evaluated implementations must
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
