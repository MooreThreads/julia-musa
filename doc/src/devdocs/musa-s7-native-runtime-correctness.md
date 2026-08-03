# MUSA S7 native runtime correctness receipt

## Result

**INCONCLUSIVE.** Gluon task `f2ce8803-69c4-4052-bf70-f356647c1f31`
started from exact accepted S6R1 result
`51182cf5ca6bfffdc1dc934fc1f78aa04f92fa58`. The one authorized run used the
byte-unchanged Julia-generated `elf64-mtgpu` `mp_31` object, loaded its exact
kernel symbol through the authentic MUSA 5.2 driver, returned exit zero, and
produced the exact frozen `UInt32` result. The concurrent utilization sampler
did not observe a nonzero process-utilization sample before the run finished.
Nonzero assigned-device activity is mandatory for GO, so the exact result is
retained without replay and no GO or formal-acceptance claim is made.

This is a representative Julia-origin native MUSA runtime and scalar
correctness receipt. It is technical evidence only, not formal acceptance or a
performance result.

## Preserved Julia-origin device input

The accepted S6R1 IR, bitcode, and object under
[`contrib/musa/s6-tooling/evidence`](../../../contrib/musa/s6-tooling/evidence)
were not regenerated or edited. Their identities after the S7 run remained:

| retained input | SHA-256 |
|---|---|
| Julia LLVM IR | `d9039731dfe190d131cd5fb99298123fe4f9005d70bfb8412e495890521eff04` |
| Julia LLVM bitcode | `58259a1e471b6f98ac2c25ee8e0210af513b8fe1c3a8f548ee5f9578ea586ff1` |
| vendor MTGPU object | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |

Vendor LLVM 14 identifies the object as `elf64-mtgpu`, architecture `mtgpu`;
its retained readback identifies calling convention `mtgpu_kernel` and
`"target-cpu"="mp_31"`. The symbol table exports
`julia_scalar_kernel`. S7 did not modify the official Julia 1.9.4/LLVM 14.0.6,
GPUCompiler 0.26.2, or LLVM.jl 6.6.0 closure and did not introduce CUDA
identity, device libraries, textual IR changes, or a CPU fallback.

## Frozen contract before device access

[`native_launcher.h`](../../../contrib/musa/s7-tooling/native_launcher.h)
freezes the contract in compiled constants. The CPU-only preflight printed the
same values before the first driver call:

| field | frozen value |
|---|---|
| object SHA-256 | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |
| symbol | `julia_scalar_kernel` |
| `x` | `0xf0000001` (`UInt32`) |
| `y` | `0x40000005` (`UInt32`) |
| oracle | `UInt32(3) * x + y == 0x10000008`, modulo `2^32` |
| initial output sentinel | `0xdeadbeef` |
| grid | `(16777216, 1, 1)` |
| block | `(256, 1, 1)` |
| dynamic shared memory | `0` bytes |
| expected process exit | `0` |
| authorized run count | exactly one |
| timeout | `600` seconds, kill on expiry |

The kernel has no thread-index argument. Every thread in the bounded large
geometry writes the same frozen scalar, retaining scalar semantics while
giving the utilization sampler a wider observation window. The returned value
is one complete `UInt32`; finite/integer checks are inherent in that type and
comparison is bit-exact.

The kernel arguments are passed as a 64-bit `MUdeviceptr`, followed by two
32-bit unsigned scalars. Compile-time assertions require offsets `0`, `8`, and
`12` and a 16-byte aggregate layout, matching the retained LLVM signature
`(i64, i32, i32)`. The arithmetic oracle uses C `uint32_t`, whose unsigned
arithmetic supplies the required modulo-`2^32` wrap semantics.

## Minimal authentic host path

The bounded launcher in
[`contrib/musa/s7-tooling`](../../../contrib/musa/s7-tooling) uses only the
MUSA 5.2 driver calls needed for this receipt:

1. `muInit(0)`, require exactly one container-visible device, and obtain sole
   ordinal `0` without accepting or requiring a physical host GPU index;
2. require the visible device name to contain `S5000` and create its context;
3. call `muModuleLoad` on the retained object and resolve only
   `julia_scalar_kernel` with `muModuleGetFunction`;
4. allocate and seed one four-byte device output, invoke `muLaunchKernel`
   exactly once, synchronize, and copy the result back; and
5. compare the returned bits directly to `0x10000008`, failing on every MUSA
   error or mismatch.

There is intentionally no unload, free, context destruction, host install,
service, database, network, credential, push, deployment, or other cleanup.
Process exit releases the process-owned resources. The executable's direct
dynamic dependencies are exactly `libmusa.so.1` and `libc.so.6`; the driver
resolves to `/usr/lib/x86_64-linux-gnu/libmusa.so.1`. It does not link
`libmusart`, CUDA, Julia, LLVM, or GPUCompiler into the host launcher.

The pre-device mock tests prove the frozen pointer/scalar layout and exact
parameters, and inject failures at module load, symbol lookup, kernel launch,
and exact output comparison. Each error returns nonzero with its sensitive
stage named, and the module/symbol failures prove that no launch follows.

## Single-run receipt and classification

[`evidence/`](../../../contrib/musa/s7-tooling/evidence) contains the immutable
one-run receipt. The executed launcher binary has SHA-256
`6b35af415f41cf28a39e589fdc483573b5b137c7c74b39f16a049ad69ef5603a`.
The runner verified the retained object digest, reran the CPU-only tests,
started the launcher under the 600-second timeout, and concurrently scanned
every readable `/proc/driver/musa/gpu*/proc_util` file. A sample qualified only
when its process name was `native_launcher` and the sum of its reported
utilization columns was nonzero; scanning all files dynamically associates the
container process with the assigned physical S5000 without a host GPU index.

The exact observed receipt was:

```text
launcher_exit=0
observed=0x10000008
expected=0x10000008
exact=true
nonzero_activity=0
run_count=1
timeout_seconds=600
```

The executed binary printed a local `GO:` prefix for its kernel-output
subcheck. That wording did not include the external activity requirement and
must not be interpreted as the task classification; the authoritative
`result.log` records `result=INCONCLUSIVE`. The retained line is preserved
verbatim rather than rewritten after observation. The source now labels this
local subcheck `KERNEL_OK` so a future, separately authorized run cannot
confuse scalar equality with the overall gate.

Thus module load, symbol resolution, the one launch, synchronization, exit
status, and exact scalar equality all returned success through the authentic
driver path. Because the required nonzero utilization observation is absent,
the environment did not establish the full device-activity gate. Replaying
with different inputs, geometry, sampling, or a second launch was prohibited
and was not attempted.

## Verification

* frozen contract and compile-time host ABI checks: PASS;
* focused mock layout/module/symbol/launch/equality checks: PASS;
* retained IR/bitcode/object identities after execution: PASS;
* direct dependency gate (`libmusa.so.1`, `libc.so.6` only): PASS;
* sole visible ordinal and S5000 guard: PASS, implied by launcher exit zero;
* authentic module load, exact symbol, one launch, synchronization: PASS by
  fail-loud driver return checks;
* output `0x10000008 == 0x10000008`: PASS, exact `UInt32` equality;
* observed nonzero assigned-device activity: **INCONCLUSIVE**, no qualifying
  concurrent sample;
* `git diff --check`: PASS;
* `make fix-whitespace`: attempted and exited 2 before checking because no
  Julia executable was available (`/bin/sh: 1: julia: not found`); no download
  or host installation was permitted; and
* overall correctness target: **INCONCLUSIVE**, no GO and no formal acceptance.
