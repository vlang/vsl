module vcl

import gg

// ImageType represents available image types
pub enum ImageType {
        intensity = C.CL_INTENSITY
        rgba = C.CL_RGBA
}

// Image memory buffer on the device with image data
pub struct Image {
mut:
	buf &Buffer
        format ClImageFormat
        desc &ClImageDesc
pub:
        @type ImageType
        bounds gg.Rect
}

// release releases the buffer on the device
pub fn (mut img Image) release() ? {
        return img.buf.release()
}

// image allocates an image buffer
pub fn (d &Device) image(@type ImageType, bounds gg.Rect) ?&Image {
        return d.create_image(@type, bounds, 0, voidptr(0))
}

// from_image creates new Image and copies data from gg.Image
pub fn (d &Device) from_image(img gg.Image) ?&Image {
        data := img.data
        mut row_pitch := 0
        mut image_type := ImageType.intensity

        if img.nr_channels in [3, 4] {
                image_type = ImageType.rgba
        }

        bounds := gg.Rect{0, 0, img.width, img.height}
        return d.create_image(image_type, bounds, row_pitch, data)
}

// create_image creates a new image
fn (d &Device) create_image(image_type ImageType, bounds gg.Rect, row_pitch int, data voidptr) ?&Image {
        return none
}
