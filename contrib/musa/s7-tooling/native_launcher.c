#include "native_launcher.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

_Static_assert(sizeof(MUdeviceptr) == sizeof(uint64_t), "MUSA device pointer must be 64-bit");
_Static_assert(sizeof(struct s7_kernel_args) == 16, "kernel argument buffer must be 16 bytes");
_Static_assert(offsetof(struct s7_kernel_args, out) == 0, "out offset must be zero");
_Static_assert(offsetof(struct s7_kernel_args, x) == 8, "x offset must be eight");
_Static_assert(offsetof(struct s7_kernel_args, y) == 12, "y offset must be twelve");

static int
fail(char *error, size_t error_size, const char *stage, MUresult result)
{
    if (error != NULL && error_size > 0)
        (void)snprintf(error, error_size, "%s failed: MUresult=%d", stage, (int)result);
    return 1;
}

static int
fail_text(char *error, size_t error_size, const char *message)
{
    if (error != NULL && error_size > 0)
        (void)snprintf(error, error_size, "%s", message);
    return 1;
}

int
s7_validate_frozen_contract(char *error, size_t error_size)
{
    uint32_t oracle = UINT32_C(3) * S7_X + S7_Y;
    struct s7_kernel_args layout = {UINT64_C(0), S7_X, S7_Y};
    if (oracle != S7_EXPECTED)
        return fail_text(error, error_size, "frozen UInt32 oracle does not match");
    if (layout.x != S7_X || layout.y != S7_Y || sizeof(layout.out) != 8)
        return fail_text(error, error_size, "frozen kernel argument layout does not match");
    if (strcmp(S7_KERNEL_SYMBOL, "julia_scalar_kernel") != 0)
        return fail_text(error, error_size, "frozen kernel symbol does not match");
    if (S7_GRID_X == 0 || S7_BLOCK_X == 0)
        return fail_text(error, error_size, "frozen launch geometry is empty");
    return 0;
}

int
s7_run(const struct s7_driver *driver, const char *object_path,
       char *error, size_t error_size, uint32_t *observed)
{
    int count = 0;
    MUdevice device = 0;
    MUcontext context = NULL;
    MUmodule module = NULL;
    MUfunction function = NULL;
    MUdeviceptr device_out = 0;
    uint32_t host_out = S7_SENTINEL;
    uint32_t x = S7_X;
    uint32_t y = S7_Y;
    char device_name[128] = {0};
    void *kernel_params[] = {&device_out, &x, &y};
    MUresult result;

    if (s7_validate_frozen_contract(error, error_size) != 0)
        return 1;
    if (driver == NULL || object_path == NULL || object_path[0] == '\0')
        return fail_text(error, error_size, "launcher arguments are invalid");

    result = driver->init(0);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muInit", result);
    result = driver->device_get_count(&count);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muDeviceGetCount", result);
    if (count != 1)
        return fail_text(error, error_size, "expected exactly one container-visible MUSA device");
    result = driver->device_get(&device, 0);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muDeviceGet(ordinal=0)", result);
    result = driver->device_get_name(device_name, (int)sizeof(device_name), device);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muDeviceGetName", result);
    if (strstr(device_name, "S5000") == NULL)
        return fail_text(error, error_size, "sole visible MUSA device is not an S5000");
    result = driver->ctx_create(&context, 0, device);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muCtxCreate", result);
    result = driver->module_load(&module, object_path);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muModuleLoad", result);
    result = driver->module_get_function(&function, module, S7_KERNEL_SYMBOL);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muModuleGetFunction(julia_scalar_kernel)", result);
    result = driver->mem_alloc(&device_out, sizeof(host_out));
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muMemAlloc", result);
    result = driver->memcpy_htod(device_out, &host_out, sizeof(host_out));
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muMemcpyHtoD", result);
    result = driver->launch_kernel(function, S7_GRID_X, 1, 1, S7_BLOCK_X, 1, 1,
                                   0, NULL, kernel_params, NULL);
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muLaunchKernel", result);
    result = driver->ctx_synchronize();
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muCtxSynchronize", result);
    result = driver->memcpy_dtoh(&host_out, device_out, sizeof(host_out));
    if (result != MUSA_SUCCESS)
        return fail(error, error_size, "muMemcpyDtoH", result);
    if (observed != NULL)
        *observed = host_out;
    if (host_out != S7_EXPECTED) {
        if (error != NULL && error_size > 0)
            (void)snprintf(error, error_size,
                           "exact mismatch: expected=0x%08" PRIx32 " observed=0x%08" PRIx32,
                           S7_EXPECTED, host_out);
        return 1;
    }
    return S7_EXPECTED_EXIT;
}

#ifndef S7_NATIVE_LAUNCHER_NO_MAIN
int
main(int argc, char **argv)
{
    static const struct s7_driver driver = {
        muInit, muDeviceGetCount, muDeviceGet, muDeviceGetName, muCtxCreate,
        muModuleLoad, muModuleGetFunction, muMemAlloc, muMemcpyHtoD,
        muLaunchKernel, muCtxSynchronize, muMemcpyDtoH
    };
    char error[256] = {0};
    uint32_t observed = S7_SENTINEL;
    int exit_code;

    if (argc == 2 && strcmp(argv[1], "--print-contract") == 0) {
        if (s7_validate_frozen_contract(error, sizeof(error)) != 0) {
            fprintf(stderr, "NO_GO: %s\n", error);
            return 1;
        }
        printf("object_sha256=%s\n", S7_OBJECT_SHA256);
        printf("symbol=%s\n", S7_KERNEL_SYMBOL);
        printf("x=0x%08" PRIx32 " y=0x%08" PRIx32 " expected=0x%08" PRIx32 "\n",
               S7_X, S7_Y, S7_EXPECTED);
        printf("grid=(%" PRIu32 ",1,1) block=(%" PRIu32 ",1,1) expected_exit=%d\n",
               S7_GRID_X, S7_BLOCK_X, S7_EXPECTED_EXIT);
        return 0;
    }
    if (argc != 2) {
        fprintf(stderr, "usage: %s OBJECT | --print-contract\n", argv[0]);
        return 64;
    }
    exit_code = s7_run(&driver, argv[1], error, sizeof(error), &observed);
    if (exit_code != 0) {
        fprintf(stderr, "NO_GO: %s\n", error);
        return exit_code;
    }
    printf("KERNEL_OK: observed=0x%08" PRIx32 " expected=0x%08" PRIx32 " exact=true\n",
           observed, S7_EXPECTED);
    return 0;
}
#endif
