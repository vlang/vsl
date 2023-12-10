module dl

import dl

pub const default_paths = [
	'libOpenCL${dl.dl_ext}',
	'/system/lib64/libOpenCL${dl.dl_ext}',
	'/system/vendor/lib64/libOpenCL${dl.dl_ext}',
	'/system/vendor/lib64/egl/libGLES_mali${dl.dl_ext}',
	'/system/vendor/lib64/libPVROCL${dl.dl_ext}',
	'/data/data/org.pocl.libs/files/lib64/libpocl${dl.dl_ext}',
	'/system/lib/libOpenCL${dl.dl_ext}',
	'/system/vendor/lib/libOpenCL${dl.dl_ext}',
	'/system/vendor/lib/egl/libGLES_mali${dl.dl_ext}',
	'/system/vendor/lib/libPVROCL${dl.dl_ext}',
	'/data/data/org.pocl.libs/files/lib/libpocl${dl.dl_ext}',
	'/system_ext/lib64/libOpenCL_system${dl.dl_ext}',
]
