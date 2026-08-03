#ifndef JULIA_MUSA_NATIVE_LAUNCHER_H
#define JULIA_MUSA_NATIVE_LAUNCHER_H

#include <stddef.h>
#include <stdint.h>

#include <musa.h>

#define S7_OBJECT_SHA256 "900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965"
#define S7_KERNEL_SYMBOL "julia_scalar_kernel"
#define S7_X UINT32_C(0xf0000001)
#define S7_Y UINT32_C(0x40000005)
#define S7_EXPECTED UINT32_C(0x10000008)
#define S7_SENTINEL UINT32_C(0xdeadbeef)
#define S7_GRID_X UINT32_C(16777216)
#define S7_BLOCK_X UINT32_C(256)
#define S7_REPEAT_COUNT UINT32_C(4096)
#define S7_EXPECTED_EXIT 0

struct s7_kernel_args {
    uint64_t out;
    uint32_t x;
    uint32_t y;
};

struct s7_driver {
    MUresult (*init)(unsigned int);
    MUresult (*device_get_count)(int *);
    MUresult (*device_get)(MUdevice *, int);
    MUresult (*device_get_name)(char *, int, MUdevice);
    MUresult (*ctx_create)(MUcontext *, unsigned int, MUdevice);
    MUresult (*module_load)(MUmodule *, const char *);
    MUresult (*module_get_function)(MUfunction *, MUmodule, const char *);
    MUresult (*mem_alloc)(MUdeviceptr *, size_t);
    MUresult (*memcpy_htod)(MUdeviceptr, const void *, size_t);
    MUresult (*launch_kernel)(MUfunction, unsigned int, unsigned int, unsigned int,
                              unsigned int, unsigned int, unsigned int,
                              unsigned int, MUstream, void **, void **);
    MUresult (*ctx_synchronize)(void);
    MUresult (*memcpy_dtoh)(void *, MUdeviceptr, size_t);
};

int s7_validate_frozen_contract(char *error, size_t error_size);
int s7_run(const struct s7_driver *driver, const char *object_path,
           char *error, size_t error_size, uint32_t *observed,
           char *observed_device_name, size_t observed_device_name_size);

#endif
