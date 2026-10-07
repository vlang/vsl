module vulkan

fn test_device_type_names_match_vulkan_values() {
	assert device_type_name(vk_physical_device_type_other) == 'Other'
	assert device_type_name(vk_physical_device_type_integrated_gpu) == 'Integrated GPU'
	assert device_type_name(vk_physical_device_type_discrete_gpu) == 'Discrete GPU'
	assert device_type_name(vk_physical_device_type_virtual_gpu) == 'Virtual GPU'
	assert device_type_name(vk_physical_device_type_cpu) == 'CPU'
	assert device_type_name(99) == 'Unknown'
}

fn test_device_type_priority_prefers_discrete_gpus() {
	assert device_type_priority(vk_physical_device_type_discrete_gpu) == 0
	assert device_type_priority(vk_physical_device_type_integrated_gpu) == 1
	assert device_type_priority(vk_physical_device_type_virtual_gpu) == 2
	assert device_type_priority(vk_physical_device_type_other) == 3
	assert device_type_priority(vk_physical_device_type_cpu) == 4
	assert device_type_priority(99) == 5
}
