extern "C" __global__ void scalar(unsigned int *out, unsigned int x, unsigned int y)
{
    *out = 3U * x + y;
}
