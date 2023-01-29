module vcldl

import dl

pub const (
	default_paths = [
		'libOpenCL${dl.dl_ext}',
		'/usr/lib/libOpenCL${dl.dl_ext}',
		'/usr/local/lib/libOpenCL${dl.dl_ext}',
		'/usr/local/lib/libpocl${dl.dl_ext}',
		'/usr/lib64/libOpenCL${dl.dl_ext}',
		'/usr/lib32/libOpenCL${dl.dl_ext}',
	]
)
