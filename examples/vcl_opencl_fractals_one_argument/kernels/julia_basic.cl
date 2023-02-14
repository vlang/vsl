__kernel void julia_basic(__write_only image2d_t outputImage)
{
    const float zoom = 0.004;
    const float moveX = -0.7;
    const float moveY = 0.27015;

    int2 pos = (int2)(get_global_id(0), get_global_id(1));
    int width = get_global_size(0);
    int height = get_global_size(1);

    float2 z = (float2)(pos.x * zoom + moveX, pos.y * zoom + moveY);

    float2 c = (float2)(-0.7269f, 0.1889f);

    int iteration = 0;
    int max_iteration = 200;

    while(iteration < max_iteration && length(z) < 2.0f)
    {
        float tmp = z.x * z.x - z.y * z.y + c.x;
        z.y = 2 * z.x * z.y + c.y;
        z.x = tmp;

        iteration++;
    }

    float ratio = (float)iteration / (float)max_iteration;
    float4 color;

    if (iteration == max_iteration) {
        color = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
    }
    else {
        color.x = ratio;
        color.y = ratio;
        color.z = ratio;
        color.w = 1.0f;
    }

    write_imagef(outputImage, pos, color);
}
