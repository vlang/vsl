module ml

#include <windows.h>

fn C.MoveFileExW(existing_file_name &u16, new_file_name &u16, flags u32) i32

const logreg_movefile_replace_existing = u32(1)

fn replace_logreg_artifact_windows(source string, destination string) ! {
	windows_source := source.replace('/', '\\')
	windows_destination := destination.replace('/', '\\')
	wide_source := windows_source.to_wide()
	wide_destination := windows_destination.to_wide()
	defer {
		unsafe {
			free(voidptr(wide_source))
			free(voidptr(wide_destination))
		}
	}
	if C.MoveFileExW(wide_source, wide_destination, logreg_movefile_replace_existing) == 0 {
		code := C.GetLastError()
		return error('failed to replace `${windows_destination}` with `${windows_source}` (Windows error ${code})')
	}
}
