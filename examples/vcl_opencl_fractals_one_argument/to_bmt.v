[translated]
module main

import os
import sokol.f

type LONG = int
type BYTE = u8
type DWORD = u32
type WORD = u16

[minify]
struct BITMAPFILEHEADER {
mut:
	bfType      WORD
	bfSize      DWORD
	bfReserved1 WORD
	bfReserved2 WORD
	bfOffBits   DWORD
}

[minify]
struct BITMAPINFOHEADER {
mut:
	biSize          DWORD
	biWidth         LONG
	biHeight        LONG
	biPlanes        WORD
	biBitCount      WORD
	biCompress      DWORD
	biSizeImage     DWORD
	biXPelsPerMeter LONG
	biYPelsPerMeter LONG
	biClrUsed       DWORD
	biClrImportant  DWORD
}

fn bmp_generator(filename string, width int, height int, data []u8) {
	mut bmp_head := BITMAPFILEHEADER{}
	mut bmp_info := BITMAPINFOHEADER{}
	size := width * height * 3
	bmp_head.bfType = 19778
	bmp_head.bfSize = size + sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)
	bmp_head.bfReserved1 = 0
	bmp_head.bfReserved2 = bmp_head.bfReserved1
	bmp_head.bfOffBits = bmp_head.bfSize - size
	bmp_info.biSize = 40
	bmp_info.biWidth = width
	bmp_info.biHeight = height
	bmp_info.biPlanes = 1
	bmp_info.biBitCount = 24
	bmp_info.biCompress = 0
	bmp_info.biSizeImage = size
	bmp_info.biXPelsPerMeter = 0
	bmp_info.biYPelsPerMeter = 0
	bmp_info.biClrUsed = 0
	bmp_info.biClrImportant = 0
	mut file := os.create('${filename}') or { panic('1') }
	unsafe {
		file.write_ptr(&bmp_head, int(sizeof(BITMAPFILEHEADER)))
	}
	file.flush()
	unsafe {
		file.write_ptr(&bmp_info, int(sizeof(BITMAPINFOHEADER)))
	}
	file.flush()
	file.write(data) or { panic('4') }
	file.flush()
	file.close()
}
