module float64

import math

// Hard cases for the f64 table-maker's dilemma, found by directed search
// over the double-double algorithms: sample an f64 output y, take the
// exact midpoint between y and the next f64, invert the function at
// ~200 bits, and evaluate the f64 inputs nearest to that inverse. Those
// inputs produce the exact results closest to an f64 midpoint, where a
// ~106-bit evaluation is most likely to round the wrong way.
//
// Over 179,640 such directed candidates (exp, log, sin, cos) the
// double-double hi component never disagreed with the 200-bit correctly
// rounded result. The closest approach to a midpoint was 2.2e-08 f64
// ulps (log), tens of millions of double-double ulps away, while the
// evaluation error is ~2^-100 relative. This is strong evidence, not a
// proof for all inputs; the proof remains the open part of
// vlang/vsl#65. The ten hardest inputs per function are pinned below
// as bit-exact regression tests.

fn test_exp_dd_hard_cases() {
	for triple in exp_dd_hard_references {
		x := math.f64_from_bits(triple[0])
		hi, lo := exp_dd(x)
		assert math.f64_bits(hi) == triple[1], 'exp_dd hard hi mismatch for input ${triple[0]}'
		lo_ref := math.f64_from_bits(triple[2])
		tol := 1e-18 * math.max(1.0, math.abs(hi))
		assert math.abs(lo - lo_ref) <= tol, 'exp_dd hard lo mismatch for input ${triple[0]}'
	}
}

fn test_log_dd_hard_cases() {
	for triple in log_dd_hard_references {
		x := math.f64_from_bits(triple[0])
		hi, lo := log_dd(x)
		assert math.f64_bits(hi) == triple[1], 'log_dd hard hi mismatch for input ${triple[0]}'
		lo_ref := math.f64_from_bits(triple[2])
		tol := 1e-28 * math.max(1.0, math.abs(hi))
		assert math.abs(lo - lo_ref) <= tol, 'log_dd hard lo mismatch for input ${triple[0]}'
	}
}

fn test_sin_dd_hard_cases() {
	for triple in sin_dd_hard_references {
		x := math.f64_from_bits(triple[0])
		hi, lo := sin_dd(x)
		assert math.f64_bits(hi) == triple[1], 'sin_dd hard hi mismatch for input ${triple[0]}'
		lo_ref := math.f64_from_bits(triple[2])
		assert math.abs(lo - lo_ref) <= 1e-28, 'sin_dd hard lo mismatch for input ${triple[0]}'
	}
}

fn test_cos_dd_hard_cases() {
	for triple in cos_dd_hard_references {
		x := math.f64_from_bits(triple[0])
		hi, lo := cos_dd(x)
		assert math.f64_bits(hi) == triple[1], 'cos_dd hard hi mismatch for input ${triple[0]}'
		lo_ref := math.f64_from_bits(triple[2])
		assert math.abs(lo - lo_ref) <= 1e-28, 'cos_dd hard lo mismatch for input ${triple[0]}'
	}
}
const exp_dd_hard_references = [
	[u64(4610287335173575697), u64(4617784333787590503), u64(13600800467744550865)], // dist 3.91e-03 ulp
	[u64(4606278169209644608), u64(4612718782658970935), u64(4372908487198276590)], // dist 4.82e-03 ulp
	[u64(4585036815381912220), u64(4607337400667956338), u64(4368401139220973597)], // dist 5.02e-03 ulp
	[u64(4601626624187120873), u64(4609682728295051664), u64(4368220990284638222)], // dist 1.50e-02 ulp
	[u64(4639864751345159511), u64(5652380993459797122), u64(5413032556407659440)], // dist 1.63e-02 ulp
	[u64(4585036815381912221), u64(4607337400667956339), u64(13591371852045650772)], // dist 2.73e-02 ulp
	[u64(4606255906186293790), u64(4612705115369714189), u64(13595720783783260895)], // dist 3.59e-02 ulp
	[u64(4585036815381912219), u64(4607337400667956338), u64(4367818816534059919)], // dist 3.73e-02 ulp
	[u64(4615119737117195311), u64(4629974800406432568), u64(13613563978058481171)], // dist 4.54e-02 ulp
	[u64(4594541296992566268), u64(4607906749046039613), u64(13590954866607619779)], // dist 5.04e-02 ulp
]
const log_dd_hard_references = [
	[u64(5538154340922647162), u64(4639246959831001209), u64(13623388872392414252)], // dist 2.24e-08 ulp
	[u64(8106274966241173803), u64(4647948372906659100), u64(4409024034458752327)], // dist 4.09e-08 ulp
	[u64(1082395284607927103), u64(13871354618988034117), u64(13632396070746436723)], // dist 7.24e-08 ulp
	[u64(2020536712646036411), u64(13869082386174292680), u64(13627892470830068112)], // dist 8.84e-08 ulp
	[u64(8035725659085770829), u64(4647853259631771769), u64(13632396065769311044)], // dist 3.49e-07 ulp
	[u64(120829766739678404), u64(13872656635104689013), u64(4409024028191549353)], // dist 3.89e-07 ulp
	[u64(1201660206950290497), u64(13871193394008810159), u64(13632396063052539059)], // dist 4.99e-07 ulp
	[u64(3557927279958187429), u64(13863257798435796772), u64(4400016822602965553)], // dist 7.40e-07 ulp
	[u64(713050811527074481), u64(13871854644084623553), u64(4409024019462533505)], // dist 8.73e-07 ulp
	[u64(9028663657229077515), u64(4649197362904110806), u64(4409024017391682224)], // dist 9.88e-07 ulp
]
const sin_dd_hard_references = [
	[u64(4606586229286482886), u64(4605416031968218158), u64(4363986186108773110)], // dist 1.03e-04 ulp
	[u64(4589229522776526758), u64(4589226469588375601), u64(13573846350701463912)], // dist 1.62e-04 ulp
	[u64(4600914843897776625), u64(4600721249087175500), u64(4359481239137657844)], // dist 1.78e-04 ulp
	[u64(4607750244810100207), u64(4606306323664499354), u64(4363983905451599716)], // dist 2.29e-04 ulp
	[u64(4606526863425448623), u64(4605380565578190804), u64(4363982910583344494)], // dist 2.85e-04 ulp
	[u64(4607956760000229542), u64(4606475399533584629), u64(13587354056201247280)], // dist 3.34e-04 ulp
	[u64(4590790703955374754), u64(4590783326212747408), u64(4350471175654472832)], // dist 3.37e-04 ulp
	[u64(4603842804083916743), u64(4603476145597743247), u64(13587353779041726157)], // dist 3.50e-04 ulp
	[u64(4603022300940832837), u64(4602791721987979546), u64(4363981634553175816)], // dist 3.56e-04 ulp
	[u64(4606362658219904134), u64(4605280840554156410), u64(4363978568533654400)], // dist 5.26e-04 ulp
]
const cos_dd_hard_references = [
	[u64(4602899502364197961), u64(4605971617585490281), u64(13587359913093966678)], // dist 9.03e-06 ulp
	[u64(4602811448917828349), u64(4606015339829596646), u64(4363987634754866221)], // dist 2.24e-05 ulp
	[u64(4602906179810667494), u64(4605968271505490360), u64(4363987625024836564)], // dist 2.30e-05 ulp
	[u64(4588454208930768315), u64(4607167508569085793), u64(13587359431825129633)], // dist 3.57e-05 ulp
	[u64(4590026751362499762), u64(4607157489676238104), u64(4363987196269888170)], // dist 4.68e-05 ulp
	[u64(4585116364720221432), u64(4607177094284538899), u64(13587359138200190954)], // dist 5.20e-05 ulp
	[u64(4595684433255190212), u64(4607035494641822685), u64(13587358933854246473)], // dist 6.34e-05 ulp
	[u64(4599327323922508710), u64(4606742144459481925), u64(13587358006797629633)], // dist 1.15e-04 ulp
	[u64(4595459001462603443), u64(4607045458933774139), u64(13587357894798825699)], // dist 1.21e-04 ulp
	[u64(4602498969716406670), u64(4606122498104268901), u64(13587356969503468836)], // dist 1.72e-04 ulp
]
