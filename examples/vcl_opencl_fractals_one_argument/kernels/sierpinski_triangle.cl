__kernel void sierpinski_triangle(__write_only image2d_t outputImage)
{
    int2 pos = (int2)(get_global_id(0), get_global_id(1));
    int width = get_global_size(0);
    int height = get_global_size(1);

    int x = pos.x;
    int y = height - pos.y - 1;

    int step = 1;
    while (step < width) {
        if ((x / step) % 3 == 1 && (y / step) % 3 == 1) {
            write_imagef(outputImage, pos, (float4)(1.0f, 1.0f, 1.0f, 1.0f));
            return;
        }
        step *= 3;
    }

    write_imagef(outputImage, pos, (float4)(0.0f, 0.0f, 0.0f, 1.0f));
}
