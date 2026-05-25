// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// Device is an alias for CudaDevice exposed at the top-level module boundary.
// Users that only need the device type can import vsl.cuda and use cuda.Device.
pub type Device = CudaDevice
