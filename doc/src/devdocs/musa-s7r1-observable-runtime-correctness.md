# MUSA S7R1 observable runtime correctness receipt

## Result

**INCONCLUSIVE.** Gluon task `5ce67cac-ea8c-4097-bb4b-52d68495c582`
started from exact accepted S7 result
`4cc67b6e4b37eb430db56bdd3fd8042f89532d94`. The one authorized S7R1
workload invocation loaded and executed the byte-unchanged Julia-origin
`elf64-mtgpu` `mp_31` object through the authentic MUSA driver. It exited zero
and returned exactly `0x10000008` after the frozen repeated-launch sequence.

The launcher PID was captured and authenticated, but the frozen sampler
recorded no qualifying assigned-device activity. Post-run inspection showed
that the sampler's product-name predicate was incompatible with the procfs
interface: it required `/proc/driver/musa/gpu*/devname` to contain `S5000`,
while those files contain node labels `mtgpu.0` through `mtgpu.7`. The launcher
had independently required its sole container-visible driver device name to
contain `S5000`; those are distinct identities and should not have been
conflated. No workload replay or post-observation telemetry change was made.
The mandatory activity gate is therefore unestablished, so this is not GO or
formal acceptance.

S7R2 removed only that false procfs product-name predicate, retained the
independent driver-reported S5000 guard, and scanned the real `mtgpu.N`
sources for a unique exact-PID row. Its one separately authorized observation
again returned the exact scalar result, but no nonzero qualifying row was
retained. S7R2 is therefore also **INCONCLUSIVE**, without replay or a claim
that the corrected observation gate passed. See
[`musa-s7r2-corrected-procfs-runtime-correctness.md`](musa-s7r2-corrected-procfs-runtime-correctness.md).

## Preserved Julia correctness denominator

The retained Julia 1.9.4/LLVM 14.0.6, GPUCompiler 0.26.2, and LLVM.jl 6.6.0
closure was not changed. The S6R1 inputs remained:

| retained input | SHA-256 |
|---|---|
| Julia LLVM IR | `d9039731dfe190d131cd5fb99298123fe4f9005d70bfb8412e495890521eff04` |
| Julia LLVM bitcode | `58259a1e471b6f98ac2c25ee8e0210af513b8fe1c3a8f548ee5f9578ea586ff1` |
| vendor MTGPU object | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |

Vendor LLVM identifies the object as `elf64-mtgpu`, architecture `mtgpu`; its
readback retains calling convention `mtgpu_kernel`, target CPU `mp_31`, and
symbol `julia_scalar_kernel`. The exact inputs remained `x = 0xf0000001` and
`y = 0x40000005`. The oracle remained the C/Julia `UInt32` expression
`3 * x + y`, modulo `2^32`, with exact expected bits `0x10000008`. There was no
CPU or CUDA fallback, regenerated object, textual IR rewrite, or changed scalar
denominator.

## Frozen observable workload and tests

Before driver access, the successor froze:

| field | value |
|---|---|
| module loads | `1` |
| symbol resolutions | `1` |
| grid | `(16777216, 1, 1)` |
| block | `(256, 1, 1)` |
| repeated launches | `256` |
| synchronization/copy/equality | once, after all launches |
| workload invocations | exactly `1` |
| timeout | `600` seconds, kill on expiry |

All launches used the same retained function and argument storage, fixed
inputs, zero dynamic shared memory, and null stream. The host copied one
complete `UInt32` only after synchronization and compared its bits directly to
the frozen oracle.

CPU-only mocks proved one module load, the exact repeat count and geometry,
one final synchronization, and fail-loud module, symbol, first-launch,
mid-sequence-launch, and equality errors. Synthetic telemetry mutations proved
that the sampler rejected a wrong PID, zero activity, a non-S5000 product name,
and a non-driver path. The last test encoded the mistaken assumption that the
procfs `devname` carried the product name; it passed but did not model the real
`mtgpu.N` node-label convention.

## One-shot receipt and telemetry diagnosis

The executed launcher had SHA-256
`5f6f45b2b041f6041bb3ce158bf72a1a4eed37b17acb5326ec6e9587ead1b215`
and direct dynamic dependencies `libmusa.so.1` and `libc.so.6` only. The runner
did not select or require a host GPU index. It accepted only one
container-visible driver device, required its driver-reported name to contain
`S5000`, and dynamically scanned every readable proc-util source for the exact
launcher PID or its visible PID.

The retained receipt is:

```text
result=INCONCLUSIVE
launcher_exit=0
pid_identity=1
nonzero_activity=0
workload_invocations=1
repeat_count=256
timeout_seconds=600
launcher_pid=846
KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true
```

`/proc/846/comm` was `native_launcher`, and `/proc/846/exe` resolved to the
executed workspace launcher while it ran. Each proc-util file exposed columns
`Pid`, `VPid`, `Total`, `2D`, `TA`, `3D`, `CMP`, `TRANSFER`, and `PidName`, so
the frozen numeric PID/activity row parser matched the actual row layout. The
separate `devname` predicate rejected every source because the values were
`mtgpu.0` through `mtgpu.7`, not product names. Consequently there is no
retained nonzero PID-associated sample, even though module load, symbol
resolution, repeated driver launches, synchronization, and exact output all
passed fail-loud checks.

The earlier S7 missed sample was not treated as a scientific failure and did
not prohibit this run. This S7R1 run is likewise not a demonstrated kernel
correctness failure: the environment and frozen instrumentation did not
establish the additional observation required for correctness GO.

## Verification

* retained IR, bitcode, and object identities: PASS;
* exact scalar inputs and `UInt32` oracle: PASS, unchanged;
* mutation-sensitive repeat-count, geometry, failure, and telemetry checks:
  PASS;
* sole visible driver ordinal and S5000 guard: PASS, implied by exit zero;
* authentic module load, symbol resolution, 256 launches, and synchronization:
  PASS through fail-loud driver checks;
* exit zero and `0x10000008 == 0x10000008`: PASS, exact equality;
* launcher PID identity: PASS;
* observed nonzero assigned-device activity: **INCONCLUSIVE**, no retained
  qualifying sample due to the frozen procfs-name mismatch;
* `git diff --check`: PASS;
* `make fix-whitespace`: attempted before device access and exited 2 because
  no `julia` executable was available (`/bin/sh: 1: julia: not found`); no
  network or host installation was used; and
* overall correctness target: **INCONCLUSIVE**, no GO, performance claim, or
  formal acceptance.
