module native

pub type ClPlatformId = voidptr
pub type ClDeviceId = voidptr
pub type ClContext = voidptr
pub type ClContextProperties = voidptr
pub type ClCommandQueue = voidptr
pub type ClMem = voidptr
pub type ClProgram = voidptr
pub type ClKernel = voidptr
pub type ClEvent = voidptr
pub type ClSampler = voidptr

pub type ClMemFlags = u64
pub type ClDeviceType = u64
pub type ClDeviceInfo = u32
pub type ClProperties = u64
pub type ClQueueProperties = u64
pub type ClProgramBuildInfo = u32

// ImageChannelOrder represents available image types
pub enum ImageChannelOrder {
	intensity = C.CL_INTENSITY
	rgba = C.CL_RGBA
}

// ImageChannelDataType describes the size of the channel data type
pub enum ImageChannelDataType {
	unorm_int8 = C.CL_UNORM_INT8
}

pub type ClMemObjectType = int
pub type ClImageDesc = voidptr
pub type ClImageFormat = voidptr
