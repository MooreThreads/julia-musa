# MUSA S7R2 corrected procfs runtime correctness receipt

## Result

**INCONCLUSIVE.** Gluon task `02a863f8-4811-4625-a549-70db97ee48e4`
started from exact accepted S7R1 result
`b4e44de5d5d0feece5b2a2c6034715f25d481461`. Before device access, S7R2
removed only the demonstrated false assumption that a procfs `devname` is a
driver product name. The corrected sampler accepts the observed `mtgpu.N`
node-label convention and retains the launcher's independent
driver-reported S5000 guard.

The sole authorized workload invocation loaded and executed the
byte-unchanged Julia-origin `elf64-mtgpu` `mp_31` object through the authentic
MUSA driver. It exited zero and returned exactly `0x10000008`. The exact
launcher PID was authenticated, and every readable proc-util source was
scanned without selecting or requiring a host GPU index. No unique nonzero
exact-PID sample was retained. The required assigned-device activity gate is
therefore unestablished: this is not correctness GO or formal acceptance, and
the workload was not replayed.

## Unchanged scientific input and workload

S7R2 did not change the Julia 1.9.4/LLVM 14.0.6, GPUCompiler 0.26.2, or
LLVM.jl 6.6.0 denominator. The retained device inputs remained:

| retained input | SHA-256 |
|---|---|
| Julia LLVM IR | `d9039731dfe190d131cd5fb99298123fe4f9005d70bfb8412e495890521eff04` |
| Julia LLVM bitcode | `58259a1e471b6f98ac2c25ee8e0210af513b8fe1c3a8f548ee5f9578ea586ff1` |
| vendor MTGPU object | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |

The object remained an authentic vendor-identified `elf64-mtgpu` object for
architecture `mtgpu`; its readback retains calling convention
`mtgpu_kernel`, target CPU `mp_31`, and exported symbol
`julia_scalar_kernel`. Exact inputs `x = 0xf0000001` and `y = 0x40000005`
and the modulo-`2^32` `UInt32(3) * x + y` oracle remained unchanged, with
expected bits `0x10000008`.

The frozen invocation also remained unchanged: one module load, one symbol
resolution, grid `(16777216, 1, 1)`, block `(256, 1, 1)`, 256 launches, zero
dynamic shared memory, null stream, one final synchronization/copy/equality
check, one workload invocation, and a 600-second kill-on-expiry timeout. There
was no CPU or CUDA fallback, object regeneration, textual IR rewrite, changed
scalar input, or performance claim.

## Corrected procfs contract

The pre-device receipt froze the real proc-util columns as `Pid`, `VPid`,
`Total`, `2D`, `TA`, `3D`, `CMP`, `TRANSFER`, and `PidName`. It also froze all
eight readable source labels:

```text
/proc/driver/musa/gpu00/devname=mtgpu.0
/proc/driver/musa/gpu01/devname=mtgpu.1
/proc/driver/musa/gpu02/devname=mtgpu.2
/proc/driver/musa/gpu03/devname=mtgpu.3
/proc/driver/musa/gpu04/devname=mtgpu.4
/proc/driver/musa/gpu05/devname=mtgpu.5
/proc/driver/musa/gpu06/devname=mtgpu.6
/proc/driver/musa/gpu07/devname=mtgpu.7
```

[`sample_procfs_once.sh`](../../../contrib/musa/s7-tooling/sample_procfs_once.sh)
scans all readable `/proc/driver/musa/gpu*/proc_util` files in one snapshot.
[`telemetry_sample.awk`](../../../contrib/musa/s7-tooling/telemetry_sample.awk)
requires the real column contract, an `mtgpu.N` label and driver proc-util
path, exactly one `native_launcher` row whose `Pid` or `VPid` equals the
authenticated launcher PID, and a nonzero sum across the six reported
activity columns. It rejects absent, zero, wrong-PID, malformed, and duplicate
exact-PID observations. The proc-util interface does not expose a per-process
memory column, so this receipt could establish activity only through those
nonzero utilization fields.

Mutation-sensitive tests accepted a real-shaped `mtgpu.0` sample and rejected
wrong proc-util columns, an S5000 product string in place of an `mtgpu.N`
label, a wrong PID, duplicate exact-PID rows across two sources, and all-zero
activity. CPU-only native mocks again proved the unchanged module/symbol
counts, geometry, repeat count, fail-loud driver stages, and exact equality.

## One-shot receipt

The retained evidence is under
[`evidence-s7r2`](../../../contrib/musa/s7-tooling/evidence-s7r2). Before the
driver invocation, the runner recorded SHA-256 identities for the sampler,
collector, tests, object, and executable plus the complete observed procfs
contract. The executed launcher SHA-256 was
`5f6f45b2b041f6041bb3ce158bf72a1a4eed37b17acb5326ec6e9587ead1b215`.
Its only direct dynamic dependencies remained `libmusa.so.1` and `libc.so.6`.

The exact retained receipt is:

```text
result=INCONCLUSIVE
launcher_exit=0
pid_identity=1
sampler_contract=1
nonzero_activity=0
workload_invocations=1
repeat_count=256
timeout_seconds=600
launcher_pid=780
KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true
```

`/proc/780/comm` was `native_launcher`, and `/proc/780/exe` resolved to the
executed workspace launcher while it ran. Exit zero also proves that the
launcher observed exactly one container-visible driver device, required its
driver name to contain `S5000`, created the context, loaded the retained
object and exact symbol, completed all launches and synchronization, and
copied back the exact expected bits through fail-loud MUSA driver calls.

This observation correction followed the two inconclusive S7 and S7R1
samplers; it was not a scientific-failure replay. S7R2 removed the known
product-name defect, but the environment still did not provide the mandatory
nonzero exact-PID observation during the one bounded invocation. No second
invocation or post-observation reinterpretation was used.

## Verification

* retained IR, bitcode, and object identities: PASS;
* unchanged scalar inputs, `UInt32` oracle, object, and frozen workload: PASS;
* real proc-util columns, `mtgpu.N` labels, and mutation-sensitive exact-PID,
  uniqueness, zero-activity, and wrong-PID tests: PASS;
* independent sole-visible-device S5000 guard: PASS, implied by exit zero;
* authentic module load, symbol resolution, 256 launches, synchronization,
  and copy: PASS through fail-loud driver checks;
* exit zero and `0x10000008 == 0x10000008`: PASS, exact equality;
* unique nonzero exact-PID assigned-device observation: **INCONCLUSIVE**, no
  qualifying sample was retained;
* `git diff --check`: PASS;
* `make fix-whitespace`: attempted before device access and exited because no
  `julia` executable was available on `PATH`; it made no changes; and
* overall correctness target: **INCONCLUSIVE**, no GO, performance claim, or
  formal acceptance.
