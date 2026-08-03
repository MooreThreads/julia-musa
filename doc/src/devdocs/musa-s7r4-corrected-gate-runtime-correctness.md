# MUSA S7R4 corrected-gate runtime correctness receipt

## Result

**GO.** Gluon task `140cf684-ad54-431e-a43e-cce8280b8f12` started from
exact accepted S7R3 result `efe0520915505efce02626ed3ad20dc8e714d4d2`.
The continuous assigned-device sampler started before the launcher, captured
and authenticated the exact launcher PID, and armed the complete start token.
The one authorized driver workload then loaded and executed the unchanged
Julia-origin object on the sole visible driver-reported `MTT S5000`, exited
zero, and returned exactly `0x10000008`.

The retained evaluator found nonzero assigned-device activity inside the
device-access interval. All correctness GO requirements therefore passed in
the first post-correction run. No artificial one-run barrier or additional
workload was added after this scientific and telemetry result. This is
technical completion only, not formal acceptance or a performance claim.

## Pre-execution gate correction

S7R3's launcher process exited before `muInit`: it opened the newly created
start-gate file after shell redirection had created it but before the six-byte
token write completed. S7R3 committed the bounded orchestration correction
which retries absent and short reads and accepts only the complete six bytes
`armed\n`. S7R4 did not change that correction after device access and did not
treat S7R3 as a scientific execution.

Before this run, CPU-only mutation checks rejected:

* the empty token;
* the short five-byte token `armed`;
* a wrong six-byte token; and
* every state except the exact complete `armed\n` token.

Those checks occur before the mock driver's first call and are retained in
[`pre-device-tests.log`](../../../contrib/musa/s7-tooling/evidence-s7r4/pre-device-tests.log).
The actual gate contains six bytes and has SHA-256
`dc05a24877302a4b56f0eddb2f8fcd2e27f99514f1e284dcd7c4ff89403573a3`.
The runner waited for the continuously sampling process to authenticate and
arm the launcher before exposing that complete token. The launcher emitted
its device-access start timestamp only after complete-token validation.

## Unchanged Julia correctness denominator

The Julia-origin inputs were not regenerated, rewritten, or edited:

| retained input | SHA-256 |
|---|---|
| Julia LLVM IR | `d9039731dfe190d131cd5fb99298123fe4f9005d70bfb8412e495890521eff04` |
| Julia LLVM bitcode | `58259a1e471b6f98ac2c25ee8e0210af513b8fe1c3a8f548ee5f9578ea586ff1` |
| vendor MTGPU object | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |

Vendor LLVM 14 still identifies the object as `elf64-mtgpu`, architecture
`mtgpu`. Its unchanged readback retains calling convention `mtgpu_kernel`,
`"target-cpu"="mp_31"`, and exported symbol `julia_scalar_kernel`. The host
launcher has only the direct dynamic dependencies `libmusa.so.1` and
`libc.so.6`; it does not link a CPU, CUDA, Julia, LLVM, GPUCompiler, or MUSA
runtime fallback.

The frozen scientific contract remained:

| field | frozen value |
|---|---|
| symbol | `julia_scalar_kernel` |
| `x` | `0xf0000001` (`UInt32`) |
| `y` | `0x40000005` (`UInt32`) |
| exact oracle | modulo-`2^32` `UInt32(3) * x + y = 0x10000008` |
| grid | `(16777216, 1, 1)` |
| block | `(256, 1, 1)` |
| dynamic shared memory and stream | `0` and null |
| module loads and symbol resolutions | one each |
| bounded launches | `4096` |
| final synchronization/copy/equality | one each |
| workload processes | exactly one |
| timeout | `600` seconds, kill on expiry |

The CPU-only mocks prove the exact arguments and geometry, one module load,
one symbol resolution, all 4096 launches, one final synchronization, and exact
equality. They also retain fail-loud module, symbol, first-launch,
mid-sequence-launch, and wrong-result mutations.

## Dynamic assignment and continuous evidence

The runner did not require, set, or infer a physical host GPU index. It found
one visible MTGPU character device, `/dev/mtgpu.0`, read its `mtgpu.0` node
label, and dynamically mapped that label to exactly one procfs directory,
`/proc/driver/musa/gpu00`. The launcher independently required exactly one
container-visible MUSA ordinal and required the driver's product name to
contain `S5000`.

The sampler captured a pre-access baseline, authenticated launcher PID `842`
as `native_launcher` with the exact executed path, and retained 7582 complete
samples from assigned-node `proc_util`, `status`, `int_status`, and `memory`
sources. It started at `1785787088219955658` ns and ended at
`1785787167229910568` ns, covering the complete device-access interval
`1785787088245284938` through `1785787167207241297` ns.

The evaluator retained 7576 samples inside that interval. Its accepted sample
at `1785787088329293739` ns records assigned-node overall utilization of 100%
and 2D utilization of 100%, producing the evaluator's aggregate status delta
of 200 from the zero baseline. This is evidence of nonzero in-window activity,
not a throughput, latency, or other performance measurement. Synthetic tests
also retained rejection of wrong-device, wrong-PID, all-zero, and
out-of-window telemetry.

## Sole invocation receipt

Evidence is retained under
[`evidence-s7r4`](../../../contrib/musa/s7-tooling/evidence-s7r4). Commands and
source hashes were frozen before device access. The executed launcher SHA-256
is `85a4e74f5064f62f9f53c4ad84a9fa3c6899618bde1896b2d1531a3c1f5a0293`;
the continuous raw log SHA-256 is
`d3ebf9d2a7dd9dd345cd2de053df2bbb4181358ee6783b24d58d998c718a28c3`.

The exact result summary is:

```text
result=GO
launcher_exit=0
sampler_exit=0
evaluator_exit=0
pid_identity=1
nonzero_activity=1
assigned_device=mtgpu.0
workload_invocations=1
repeat_count=4096
timeout_seconds=600
```

The launcher retained:

```text
launcher_pid=842
device_access_start_ns=1785787088245284938
device_access_end_ns=1785787167207241297
driver_device_name=MTT S5000
KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true
```

Empty launcher and sampler stderr logs, their zero exits, the driver's S5000
name, fail-loud module/symbol/launch/synchronization calls, and the bit-exact
result establish the genuine unchanged-object path without a CPU or CUDA
fallback. The successful continuous evaluator independently establishes the
required dynamically assigned device activity.

## Verification

* exact base commit and clean starting worktree: PASS;
* empty, short, wrong, and correct complete gate-token mutations before driver
  access: PASS;
* retained IR, bitcode, object, `elf64-mtgpu`, `mp_31`, symbol, scalars,
  geometry, bounded count, and `UInt32` oracle: PASS;
* wrong-device, wrong-PID, zero, and out-of-window continuous telemetry
  mutations: PASS;
* continuous sampler start, authenticated launcher PID, and complete coverage:
  PASS;
* sole visible driver-reported S5000, genuine module/symbol execution, 4096
  launches, synchronization, and copy: PASS;
* launcher exit zero and exact `0x10000008 == 0x10000008`: PASS;
* retained nonzero in-window dynamically assigned-device activity: PASS;
* `git diff --check`: PASS before device access;
* `make fix-whitespace`: attempted before device access and exited 2 because
  `julia` was unavailable on `PATH`; it made no changes; and
* overall correctness target: **GO**, with no replay, performance claim, or
  formal acceptance.
