module dl

import dl.loader

// Vulkan internal dynamic library loader.
// Follows the same pattern as vsl.vcl.internal.dl — uses V's standard
// dl.loader.DynamicLibLoader to resolve Vulkan functions at runtime.
//
// Environment variable VULKAN_LIB_PATH overrides the default library path.
// On Linux: libvulkan.so.1
// On macOS: libvulkan.1.dylib
// On Windows: vulkan-1.dll

pub const dl_no_path_issue_code = loader.dl_no_path_issue_code
pub const dl_open_issue_code = loader.dl_open_issue_code
pub const dl_sym_issue_code = loader.dl_sym_issue_code
pub const dl_close_issue_code = loader.dl_close_issue_code
pub const dl_register_issue_code = loader.dl_register_issue_code

fn get_or_create_dynamic_lib_loader() !&loader.DynamicLibLoader {
	return loader.get_or_create_dynamic_lib_loader(
		key:      @MOD + '.' + 'LibVulkan'
		env_path: 'VULKAN_LIB_PATH'
		paths:    default_paths
	)
}

fn cleanup() {
	mut dl_loader := get_or_create_dynamic_lib_loader() or { return }
	dl_loader.unregister()
}

fn init() {
	mut dl_loader := get_or_create_dynamic_lib_loader() or { return }
	dl_loader.open() or { return }
}

pub fn get_sym(name string) !voidptr {
	mut dl_loader := get_or_create_dynamic_lib_loader()!
	return dl_loader.get_sym(name)
}
