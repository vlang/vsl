module vcl

type ClPlatformId = voidptr
type ClDeviceId = voidptr
type ClContext = voidptr
type ClContextProperties = voidptr
type ClCommandQueue = voidptr
type ClMem = voidptr
type ClProgram = voidptr
type ClKernel = voidptr
type ClEvent = voidptr
type ClSampler = voidptr

type ClMemFlags = u64
type ClDeviceType = u64
type ClDeviceInfo = u32
type ClProperties = u64
type ClQueueProperties = u64
type ClProgramBuildInfo = u32

// ImageChannelOrder represents available image types
pub enum ImageChannelOrder {
	intensity = C.CL_INTENSITY
	rgba = C.CL_RGBA
}

// ImageChannelDataType describes the size of the channel data type
pub enum ImageChannelDataType {
	unorm_int8 = C.CL_UNORM_INT8
}

type ClMemObjectType = int
type ClImageDesc = voidptr
type ClImageFormat = voidptr
