#define _POSIX_C_SOURCE 200809L

#include "native_launcher.h"

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

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
    if (S7_GRID_X != UINT32_C(16777216) || S7_BLOCK_X != UINT32_C(256))
        return fail_text(error, error_size, "frozen launch geometry does not match");
    if (S7_REPEAT_COUNT != UINT32_C(4096))
        return fail_text(error, error_size, "frozen repeat count does not match");
    if (S7_GRID_X == 0 || S7_BLOCK_X == 0 || S7_REPEAT_COUNT == 0)
        return fail_text(error, error_size, "frozen launch geometry is empty");
    return 0;
}

int
s7_run(const struct s7_driver *driver, const char *object_path,
       char *error, size_t error_size, uint32_t *observed,
       char *observed_device_name, size_t observed_device_name_size)
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
    uint32_t launch;

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
    if (observed_device_name != NULL && observed_device_name_size > 0)
        (void)snprintf(observed_device_name, observed_device_name_size, "%s", device_name);
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
    for (launch = 0; launch < S7_REPEAT_COUNT; launch++) {
        result = driver->launch_kernel(function, S7_GRID_X, 1, 1, S7_BLOCK_X, 1, 1,
                                       0, NULL, kernel_params, NULL);
        if (result != MUSA_SUCCESS)
            return fail(error, error_size, "muLaunchKernel", result);
    }
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
static int
start_gate_token_valid(const char *token, ssize_t bytes)
{
    return bytes == 6 && memcmp(token, "armed\n", 6) == 0;
}

static uint64_t
realtime_ns(void)
{
    struct timespec now;
    if (clock_gettime(CLOCK_REALTIME, &now) != 0)
        return 0;
    return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

static int
wait_for_start_gate(const char *path, char *error, size_t error_size)
{
    const struct timespec retry = {0, 1000000};
    char token[7] = {0};
    int descriptor;
    ssize_t bytes;

    for (;;) {
        descriptor = open(path, O_RDONLY);
        if (descriptor >= 0) {
            bytes = read(descriptor, token, sizeof(token) - 1);
            (void)close(descriptor);
            if (start_gate_token_valid(token, bytes))
                return 0;
            if (bytes == (ssize_t)(sizeof(token) - 1))
                break;
            if (bytes < 0)
                return fail_text(error, error_size, "start gate read failed");
        }
        else if (errno != ENOENT)
            return fail_text(error, error_size, "start gate open failed");
        (void)nanosleep(&retry, NULL);
    }
    return fail_text(error, error_size, "start gate token does not match");
}

int
main(int argc, char **argv)
{
    static const struct s7_driver driver = {
        muInit, muDeviceGetCount, muDeviceGet, muDeviceGetName, muCtxCreate,
        muModuleLoad, muModuleGetFunction, muMemAlloc, muMemcpyHtoD,
        muLaunchKernel, muCtxSynchronize, muMemcpyDtoH
    };
    char error[256] = {0};
    char device_name[128] = {0};
    uint32_t observed = S7_SENTINEL;
    const char *object_path;
    const char *start_gate = NULL;
    uint64_t access_start_ns;
    uint64_t access_end_ns;
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
        printf("grid=(%" PRIu32 ",1,1) block=(%" PRIu32 ",1,1) repeat_count=%" PRIu32
               " expected_exit=%d\n",
               S7_GRID_X, S7_BLOCK_X, S7_REPEAT_COUNT, S7_EXPECTED_EXIT);
        return 0;
    }
    if (argc == 2) {
        object_path = argv[1];
    }
    else if (argc == 4 && strcmp(argv[1], "--start-gate") == 0) {
        start_gate = argv[2];
        object_path = argv[3];
    }
    else {
        fprintf(stderr, "usage: %s OBJECT | --start-gate FILE OBJECT | --print-contract\n",
                argv[0]);
        return 64;
    }
    printf("launcher_pid=%jd\n", (intmax_t)getpid());
    (void)fflush(stdout);
    if (start_gate != NULL && wait_for_start_gate(start_gate, error, sizeof(error)) != 0) {
        fprintf(stderr, "NO_GO: %s\n", error);
        return 1;
    }
    access_start_ns = realtime_ns();
    printf("device_access_start_ns=%" PRIu64 "\n", access_start_ns);
    (void)fflush(stdout);
    exit_code = s7_run(&driver, object_path, error, sizeof(error), &observed,
                       device_name, sizeof(device_name));
    access_end_ns = realtime_ns();
    printf("device_access_end_ns=%" PRIu64 "\n", access_end_ns);
    if (device_name[0] != '\0')
        printf("driver_device_name=%s\n", device_name);
    (void)fflush(stdout);
    if (exit_code != 0) {
        fprintf(stderr, "NO_GO: %s\n", error);
        return exit_code;
    }
    printf("KERNEL_OK: observed=0x%08" PRIx32 " expected=0x%08" PRIx32 " exact=true\n",
           observed, S7_EXPECTED);
    return 0;
}
#endif
