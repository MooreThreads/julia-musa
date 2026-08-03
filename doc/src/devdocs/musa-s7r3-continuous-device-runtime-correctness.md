# MUSA S7R3 continuous device runtime correctness receipt

## Result

**NO_GO.** Gluon task `8de06fce-5709-4817-bf85-3b25870f9966` started from
exact accepted S7R2 result `21479c3ee308a1d55a8a8ebe67d1550a695895e6`.
S7R3 froze a bounded continuous assigned-device sampler before device access,
authenticated its exact launcher PID, and retained timestamped raw samples
from every selected per-process and global activity source. The sole launcher
invocation then exited 1 at the start gate, before calling `muInit` or accessing
the MUSA driver. No workload replay was performed.

This is a demonstrated orchestration failure, not a scientific failure of the
Julia object or S5000. It cannot establish driver-reported S5000, genuine
object execution, exact output, or nonzero in-window activity, so correctness
GO is prohibited. This is technical completion only, not formal acceptance.

The separately authorized S7R4 successor exercised the already committed
complete-token retry without changing the scientific workload. Its sole
driver invocation exited zero, returned exactly `0x10000008`, and retained
nonzero in-window activity from the dynamically assigned S5000. That result is
**GO** and is recorded without another replay in
[`musa-s7r4-corrected-gate-runtime-correctness.md`](musa-s7r4-corrected-gate-runtime-correctness.md).
It does not alter this S7R3 orchestration-failure classification.

## Preserved correctness denominator

The Julia-origin object was not changed or regenerated:

| retained input | frozen value |
|---|---|
| object SHA-256 | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |
| vendor identity | `elf64-mtgpu`, architecture `mtgpu`, CPU `mp_31` |
| calling convention and symbol | `mtgpu_kernel`, `julia_scalar_kernel` |
| scalars | `x = 0xf0000001`, `y = 0x40000005` |
| oracle | modulo-`2^32` `UInt32(3) * x + y = 0x10000008` |
| grid and block | `(16777216, 1, 1)`, `(256, 1, 1)` |
| module loads and symbol resolutions | one each |
| final synchronization/copy/equality | one each, after all launches |

Only the permitted observation batch count changed, from 256 to the bounded
maximum 4096. The launcher mocks prove the exact count, unchanged geometry and
arguments, one module load, one final synchronization, exact equality, and
fail-loud first-launch, mid-launch, module, symbol, and copy-result failures.
The launcher retains only direct `libmusa.so.1` and `libc.so.6` dependencies;
there is no CPU or CUDA fallback.

## Continuous assigned-device observation

The runner did not set, accept, or infer a host GPU index. It dynamically found
the sole visible MTGPU character device `/dev/mtgpu.0`, read its node label
`mtgpu.0`, and required exactly one matching procfs directory,
`/proc/driver/musa/gpu00`. The node label is the mapping key, not a pinned host
ordinal or a product-name substitute.

[`sample_device_continuously.sh`](../../../contrib/musa/s7-tooling/sample_device_continuously.sh)
records nanosecond timestamps and unmodified raw contents from the assigned
device's readable `proc_util`, `status`, `int_status`, and `memory` sources.
It takes a baseline, writes its readiness marker, authenticates `/proc/PID/comm`
and `/proc/PID/exe`, takes another sample, and only then arms the launch gate.
It continues polling at a frozen 5 ms interval until the launcher's completion
marker, with a hard bound of 120000 samples.

[`evaluate_continuous_telemetry.awk`](../../../contrib/musa/s7-tooling/evaluate_continuous_telemetry.awk)
requires sampler coverage before the device-access start and through its end.
Within that exact interval it accepts either a nonzero `native_launcher` row
whose `Pid` or `VPid` equals the authenticated PID, or a positive assigned-node
delta in cumulative interrupt counters or global utilization relative to the
pre-access baseline. It rejects a wrong assigned device or procfs directory,
wrong PID, all-zero evidence, missing sources, malformed records, and activity
outside the device-access window. Synthetic mutation tests cover every one of
those acceptance paths and required rejections.

The retained pre-access interface is:

```text
assigned_device_node=/dev/mtgpu.0
assigned_device_label=mtgpu.0
assigned_procfs_dir=/proc/driver/musa/gpu00
proc_util columns=Pid VPid Total 2D TA 3D CMP TRANSFER PidName
global sources=status int_status memory
```

## Sole invocation and gate diagnosis

Evidence is retained under
[`evidence-s7r3`](../../../contrib/musa/s7-tooling/evidence-s7r3). The invoked
launcher SHA-256 was
`25d8d620e70a69a9a687471e5eb1eb02212caaebd865432195746217a3cc2d0d`.
The continuous raw log SHA-256 is
`060d009d06e5ad955615fb08709890f9e415bfc1567c14b30116397ded5c085c`.
It retains sampler start/end records, five complete raw samples, and the exact
authenticated identity:

```text
@launcher_identity pid=1079 comm=native_launcher exe=/workspace/contrib/musa/s7-tooling/native_launcher
```

The exact runner receipt was:

```text
result=NO_GO
launcher_exit=1
sampler_exit=0
evaluator_exit=1
pid_identity=1
nonzero_activity=0
assigned_device=mtgpu.0
workload_invocations=1
repeat_count=4096
timeout_seconds=600
```

Here `workload_invocations=1` counts the sole launched workload process. The
more precise post-run diagnosis records `device_access_started=0` and
`driver_workload_invocations=0`: stdout contains only `launcher_pid=1079`, and
stderr is exactly `NO_GO: start gate token does not match`.

Both retained `sampler.armed` and `start.gate` contain the correct six bytes
`armed\n` and have SHA-256
`dc05a24877302a4b56f0eddb2f8fcd2e27f99514f1e284dcd7c4ff89403573a3`.
The failure was a file-creation race: shell redirection created the gate as an
empty file before writing the token, while the launcher's existence poll could
open and read that transient empty state. The committed launcher correction
retries short reads and validates only a complete six-byte token. Consistent
with the one-invocation rule, that correction was tested without device access
and the driver workload was not replayed.

## Verification

* exact base commit and clean starting worktree: PASS;
* retained object hash and vendor `elf64-mtgpu`/`mp_31` readback: PASS;
* unchanged scalar inputs, geometry, symbol, and exact `UInt32` oracle: PASS;
* bounded 4096-count mocks with one final synchronization/copy: PASS;
* wrong-device, wrong-PID, zero, and out-of-window telemetry mutations: PASS;
* sampler start-before-access design and authenticated PID arm: PASS;
* sole launcher invocation and no replay: PASS;
* genuine MUSA driver execution and driver-reported S5000: **NO_GO**, device
  access never started;
* launcher exit zero and exact `0x10000008`: **NO_GO**, no result was produced;
* retained nonzero in-window assigned-device activity: **NO_GO**, no access
  window existed;
* `git diff --check`: PASS before the invocation;
* `make fix-whitespace`: attempted before the invocation and exited 2 because
  `julia` was unavailable on `PATH`; it made no changes; and
* overall correctness target: **NO_GO**, with no performance claim or formal
  acceptance.
