#define S7_NATIVE_LAUNCHER_NO_MAIN
#include "native_launcher.c"

#include <assert.h>

static int call_index;
static int fail_index;
static int launch_calls;
static uint32_t copied_value;

static MUresult
step(void)
{
    call_index++;
    return call_index == fail_index ? MUSA_ERROR_INVALID_VALUE : MUSA_SUCCESS;
}

static MUresult mock_init(unsigned int flags) { assert(flags == 0); return step(); }
static MUresult mock_count(int *count) { *count = 1; return step(); }
static MUresult mock_device(MUdevice *device, int ordinal)
{ assert(ordinal == 0); *device = 7; return step(); }
static MUresult mock_name(char *name, int length, MUdevice device)
{ assert(device == 7); (void)snprintf(name, (size_t)length, "MTT S5000"); return step(); }
static MUresult mock_context(MUcontext *context, unsigned int flags, MUdevice device)
{ assert(flags == 0 && device == 7); *context = (MUcontext)(uintptr_t)1; return step(); }
static MUresult mock_module(MUmodule *module, const char *path)
{ assert(strcmp(path, "retained.o") == 0); *module = (MUmodule)(uintptr_t)2; return step(); }
static MUresult mock_function(MUfunction *function, MUmodule module, const char *symbol)
{
    assert(module == (MUmodule)(uintptr_t)2);
    assert(strcmp(symbol, S7_KERNEL_SYMBOL) == 0);
    *function = (MUfunction)(uintptr_t)3;
    return step();
}
static MUresult mock_alloc(MUdeviceptr *pointer, size_t size)
{ assert(size == sizeof(uint32_t)); *pointer = UINT64_C(0x12345678); return step(); }
static MUresult mock_htod(MUdeviceptr pointer, const void *source, size_t size)
{
    assert(pointer == UINT64_C(0x12345678) && size == sizeof(uint32_t));
    assert(*(const uint32_t *)source == S7_SENTINEL);
    return step();
}
static MUresult mock_launch(MUfunction function, unsigned int gx, unsigned int gy,
                            unsigned int gz, unsigned int bx, unsigned int by,
                            unsigned int bz, unsigned int shared, MUstream stream,
                            void **params, void **extra)
{
    launch_calls++;
    assert(function == (MUfunction)(uintptr_t)3);
    assert(gx == S7_GRID_X && gy == 1 && gz == 1);
    assert(bx == S7_BLOCK_X && by == 1 && bz == 1);
    assert(shared == 0 && stream == NULL && extra == NULL);
    assert(*(MUdeviceptr *)params[0] == UINT64_C(0x12345678));
    assert(*(uint32_t *)params[1] == S7_X && *(uint32_t *)params[2] == S7_Y);
    return step();
}
static MUresult mock_sync(void) { return step(); }
static MUresult mock_dtoh(void *destination, MUdeviceptr pointer, size_t size)
{
    assert(pointer == UINT64_C(0x12345678) && size == sizeof(uint32_t));
    *(uint32_t *)destination = copied_value;
    return step();
}

static const struct s7_driver mock_driver = {
    mock_init, mock_count, mock_device, mock_name, mock_context, mock_module,
    mock_function, mock_alloc, mock_htod, mock_launch, mock_sync, mock_dtoh
};

static void
reset(int failure)
{
    call_index = 0;
    fail_index = failure;
    launch_calls = 0;
    copied_value = S7_EXPECTED;
}

int
main(void)
{
    char error[256] = {0};
    uint32_t observed = 0;

    assert(s7_validate_frozen_contract(error, sizeof(error)) == 0);
    reset(0);
    assert(s7_run(&mock_driver, "retained.o", error, sizeof(error), &observed) == 0);
    assert(observed == S7_EXPECTED && launch_calls == 1);

    reset(6);
    assert(s7_run(&mock_driver, "retained.o", error, sizeof(error), NULL) == 1);
    assert(strstr(error, "muModuleLoad failed") != NULL && launch_calls == 0);
    reset(7);
    assert(s7_run(&mock_driver, "retained.o", error, sizeof(error), NULL) == 1);
    assert(strstr(error, "muModuleGetFunction") != NULL && launch_calls == 0);
    reset(10);
    assert(s7_run(&mock_driver, "retained.o", error, sizeof(error), NULL) == 1);
    assert(strstr(error, "muLaunchKernel failed") != NULL && launch_calls == 1);

    reset(0);
    copied_value = S7_EXPECTED + UINT32_C(1);
    assert(s7_run(&mock_driver, "retained.o", error, sizeof(error), NULL) == 1);
    assert(strstr(error, "exact mismatch") != NULL && launch_calls == 1);

    puts("PASS: frozen layout, module/symbol/launch failures, and exact equality");
    return 0;
}
