module vcldl

import dl

pub const (
	default_paths = [
		'libOpenCL${dl.dl_ext}',
		'/System/Library/Frameworks/OpenCL.framework/OpenCL',
	]
)
