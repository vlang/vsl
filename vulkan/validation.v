module vulkan

// validation.v — Vulkan validation layer support.
//
// When NOT built with -prod, new_device() will attempt to enable
// VK_LAYER_KHRONOS_validation and print validation messages to stderr.
// In production builds (-prod) the layer is omitted for performance.
//
// Usage: identical to before — just call new_device()! and validation
// layers are activated automatically in debug mode if available.

// is_validation_layer_available returns true if VK_LAYER_KHRONOS_validation
// is present in the instance layer enumeration.
fn is_validation_layer_available() bool {
	mut count := u32(0)
	res := vk_enumerate_instance_layer_properties(&count, unsafe { nil })
	if res != result_success || count == 0 {
		return false
	}
	mut props := unsafe { []C.VkLayerProperties{len: int(count)} }
	res2 := vk_enumerate_instance_layer_properties(&count, unsafe { &props[0] })
	if res2 != result_success {
		return false
	}
	target := khronos_validation_layer_name
	for i := 0; i < int(count); i++ {
		mut name := ''
		for c in props[i].layerName {
			if c == 0 {
				break
			}
			name += c.ascii_str()
		}
		if name == target {
			return true
		}
	}
	return false
}

// create_instance_debug creates a VkInstance with VK_LAYER_KHRONOS_validation
// enabled (if available). Used in debug/non-prod builds.
fn create_instance_debug() !VkInstance {
	if !is_validation_layer_available() {
		eprintln('vulkan: validation layer VK_LAYER_KHRONOS_validation not available; falling back to no-validation instance')
		return create_instance_plain()
	}

	layer_name := khronos_validation_layer_name.str
	app_info := C.VkApplicationInfo{
		sType:              structure_type_application_info
		pApplicationName:   c'vsl'
		applicationVersion: 1
		pEngineName:        c'vsl'
		engineVersion:      1
		apiVersion:         0 // VK_API_VERSION_1_0 = 0 means "any"
	}
	create_info := C.VkInstanceCreateInfo{
		sType:                   structure_type_instance_create_info
		pApplicationInfo:        &app_info
		enabledLayerCount:       1
		ppEnabledLayerNames:     &layer_name
		enabledExtensionCount:   0
		ppEnabledExtensionNames: unsafe { nil }
	}
	mut inst := VkInstance(unsafe { nil })
	res := vk_create_instance(&create_info, unsafe { nil }, &inst)
	if res != result_success {
		eprintln('vulkan: failed to create instance with validation layers (${res.str()}); retrying without')
		return create_instance_plain()
	}
	eprintln('vulkan: VK_LAYER_KHRONOS_validation enabled')
	return inst
}

// create_instance_plain creates a VkInstance without any layers.
fn create_instance_plain() !VkInstance {
	mut inst := VkInstance(unsafe { nil })
	vk_create_instance_simple(unsafe { nil }, 1, unsafe { nil }, 1, &inst)!
	return inst
}
