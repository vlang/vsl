__kernel void sierpinski_triangle2(__write_only image2d_t outputImage)
{
    int2 pos = (int2)(get_global_id(0), get_global_id(1));
    int width = get_global_size(0);

    int level = 7; // Počet úrovní rekurzie
    int size = 256; // Šírka trojuholníka

    for(int i = level; i >= 0; i--)
    {
        if(pos.x % (int)pow((float)2, (float)i) == 0 && pos.y % (int)pow((float)2, (float)i) == 0)
        {
            float4 color = (float4)(1.0f, 1.0f, 1.0f, 1.0f);
            int dist = 0;
            for(int j = 0; j <= i; j++)
            {
                if(pos.x % (int)pow((float)2, (float)(j + 1)) >=
                 (int)pow((float)2, (float)j) && pos.y % (int)pow((float)2, (float)(j + 1))
                  >= (int)pow((float)2, (float)j))
                {
                    dist = pow((float)2, (float)j);
                }
            }
            if(dist == 0)
            {
                color = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
            }
            write_imagef(outputImage, pos, color);
            return;
        }
    }
}
