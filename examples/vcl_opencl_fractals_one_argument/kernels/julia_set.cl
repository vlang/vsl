__kernel void julia_set(__write_only image2d_t outputImage)
{
    const float zoom = 0.004;
    const float moveX = -0.8;
    const float moveY = 0.156;

    int2 pos = (int2)(get_global_id(0), get_global_id(1));
    int width = get_global_size(0);
    int height = get_global_size(1);

    float2 z = (float2)(pos.x * zoom + moveX, pos.y * zoom + moveY);
    float2 c = (float2)(-0.4f, 0.6f);

    int iteration = 0;
    int max_iteration = 100;

    while(iteration < max_iteration && length(z) < 2.0f)
    {
        float2 zn;
        zn.x = z.x * z.x - z.y * z.y + c.x;
        zn.y = 2 * z.x * z.y + c.y;

        z = zn;
        iteration++;
    }

    float ratio = (float)iteration / (float)max_iteration;
    float4 color;

    if (iteration == max_iteration) {
        color = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
    }
    else {
        float value = (float)iteration;
        color.x = fmod(value, 17.0f) / 17.0f;
        color.y = fmod(value, 19.0f) / 19.0f;
        color.z = fmod(value, 23.0f) / 23.0f;
        color.w = 1.0f;
    }

    write_imagef(outputImage, pos, color);
}
