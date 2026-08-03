# MUSA S5 fail-loud target adapter contract

## Result

This implementation was produced by Gluon task
`4a482737-02e4-4d39-b215-94c1e46b76d2` from exact accepted S4
independent-review result `0d181d34188752df53f3097cf19e091f2ca32e06`.

**PASS for the isolated, fail-before-backend adapter slice. NO_GO remains for
Julia-to-MTGPU object generation.** The adapter records the target and scalar
device ABI without claiming that MUSA 5.2.0's LLVM 14 backend accepts LLVM 18
or LLVM 21 input. It performs no textual downgrade and provides no runtime,
launch, driver, or GPU path.

The tracked boundary is [`contrib/musa`](../../../contrib/musa). It is not
included by Julia's build or loaded into Base. Its exact contract is:

| Field | S5 value |
|---|---|
| Triple | `mtgpu-mt-musa` |
| CPU | `mp_31` only |
| Data layout | `e-p:64:64:64:64-p1:64:64:64:64-p2:64:64:64:64-p3:32:32-p4:32:32-p5:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128` |
| Kernel convention | MTGPU convention 102; vendor spelling `mtgpu_kernel` |
| Address spaces | space 0 supported for the scalar slice; spaces 1--5 declared by the layout but rejected until their semantics are authoritative |
| Device libraries | mode `none`; LLVM 14 `libdevice.bc` and `libdevice.31.bc` are explicitly blocked |
| Host state | `swiftcc`, Julia runtime declarations, GC state, PTLS and safepoints rejected |
| Backend preflight | MTGPU target, matching producer/input/backend LLVM major, and `musa-5.2-mtgpu-mp31` ABI attestation all required before invocation |

The final-IR check reads a serialization only to reject unsupported input. It
returns no rewritten IR. The only external-backend entry point in this slice is
`invoke_backend`, which runs backend preflight and the device ABI check before
calling the supplied backend function. Tests count invocations and prove that
the count stays zero for each rejected case.

Calling-convention ID 102 is not portable by number: LLVM 18.1.7 serializes it
as an unrelated AArch64 SME convention rather than vendor `mtgpu_kernel`.
Consequently the GPUCompiler module-finalization hook also fails loud instead
of stamping ID 102. A future producer must implement and attest the MTGPU
calling-convention dialect; numeric substitution is explicitly not accepted.

## Pinned Julia compiler dependencies

The official Julia 1.12.6 Linux x86-64 archive was reacquired into an ignored
task root. Its SHA-256 is
`bbabf3bef19421a9dbd24a767d807606ab85e444323b5a1c73ffe293fa3d079a`,
matching S4, and it reports Julia `1.12.6`, LLVM `18.1.7`, and two Julia
threads. Nothing was installed on the host.

GPUCompiler conventions were read from official release `v2.1.1`, repository
commit `7dd4056d9144e20e5a2912be9e81eda1c7d59336`. The downloaded source archive
SHA-256 is
`b80f8794fbdbb0f64b97855fc62e8d6010532b2c75dfb6663eb9a93350df3114`.
The package environment was then resolved from General snapshot
`c48a9d92bcba2ff47f8900ca572471df81a6e51c`; the snapshot archive SHA-256 is
`c888da747c9512b337d465533037e2e9465e15e2997ec08c3fc3dba6b40b253d`.
The tracked manifest pins:

| Package | Version | Registry tree |
|---|---:|---|
| GPUCompiler.jl | 2.1.1 | `f7e46a42b89ea802eff4f95427050ed386ccde37` |
| LLVM.jl | 9.11.0 | `39c054c8fd8cef1d405ba7e399d70710fdbae46c` |

GPUCompiler's relevant current conventions are an immutable
`AbstractCompilerTarget`, explicit `llvm_triple`/`llvm_datalayout`, target
module finalization, target-library policy, device codegen without Julia
runtime or entry safepoints, IR validation, and a distinct machine-code stage.
The S5 adapter uses those seams and makes `llvm_machine` fail when the
in-process LLVM lacks an attested MTGPU backend; its module-finalization seam
also rejects the unimplemented MTGPU calling-convention dialect.

## Exact supported and blocked matrix

| Producer input | Candidate backend | Result | Reason |
|---|---|---|---|
| Vendor MUSA source | MUSA 5.2.0 LLVM 14 MTGPU, `mp_31` | PASS control only | Produces an `EM_MTGPU` object; no Julia input is involved |
| Julia 1.12.6 LLVM 18 | MUSA 5.2.0 LLVM 14 MTGPU | **NO_GO** | LLVM major mismatch; real backend also rejects opaque `ptr`, then LLVM 18 `memory(...)` |
| This checkout's pinned LLVM 21 | MUSA 5.2.0 LLVM 14 MTGPU | **NO_GO** | LLVM major mismatch before backend invocation |
| Julia LLVM 18 or 21 | Same-major LLVM without MTGPU | **NO_GO** | MTGPU target absent |
| Julia LLVM 18 or 21 | Same-major MTGPU without vendor ABI attestation | **NO_GO** | `musa-5.2-mtgpu-mp31` contract not established |
| Device scalar IR | Same-major MTGPU with ABI attestation | preflight only | IR must still pass triple/layout/CPU/calling-convention/host-state/address-space/library gates; object generation is not demonstrated |

The remaining backend requirement is therefore exact: an MTGPU backend at the
same LLVM major as the Julia module producer, with vendor support for the
recorded MUSA 5.2.0 `mp_31` ABI and compatible device libraries where needed.
For the source checkout that means LLVM 21; for the authenticated Julia 1.12.6
control it means LLVM 18. Vendor LLVM 14 satisfies neither frontier.

## CPU-only frontier reproduction

The already-present `/usr/local/musa` was inspected and invoked read-only; S5
did not install or modify it. It reports MUSA 5.2.0, LLVM 14.0.0, MTCC commit
`8a8cb2971e3084fc442baeacb7447e3d73263dc8`, and targets `X86 MTGPU`.
Its `libdevice.bc` and `trap_handler.o` hashes match the authenticated S4
identities. With inherited `MUSA_HOME` and `LD_LIBRARY_PATH` unset,
`contrib/musa/test/scalar.mu` compiled for `mp_31`. Bundle listing returned:

```text
musa-mtgpu-mt-musa-mp_31
host-x86_64-unknown-linux-gnu
```

The carrier SHA-256 is
`60a88cc9a8d1d479837a7df3133f45b6089982d47e2413d82c471aaf3a81e8fb`.
The extracted image SHA-256 is
`589ab7d78ee9680dee19746c2f1abd7956355c1850aa37fc4d58e6c9b2a74efc`;
vendor `llvm-readelf` reports ELF64, DYN, `EM_MTGPU`. This is a compiler
control, not GPU execution.

Fresh Julia 1.12.6 IR for `UInt32(3) * x + y` has SHA-256
`9944f755bd9a087e3c00cd64757ddc7c30974649d96f6720038a54cbd03908a5`.
It contains the x86-64 host triple, `swiftcc`, GC stack, safepoint and LLVM 18
`memory(...)` attributes. Unmodified submission to vendor `llc` exited 1 at
opaque `ptr`. Submission with the vendor's `-opaque-pointers` flag also exited
1 at `memory(read, inaccessiblemem: readwrite)`. No rewrite or replacement
LLVM was attempted.

## Checks

All compilation and tests used `JULIA_NUM_THREADS=2` and/or
`OMP_NUM_THREADS=2` as applicable. No GPU or runtime query occurred.

* direct focused tests: PASS, 42 checks across target/policy, backend
  preflight, device ABI and ordinary Julia behavior;
* `Pkg.test(; allow_reresolve=false)`: PASS, including all 42 focused checks and
  the low-level calling-convention and target-CPU assertions;
* vendor `mp_31` compile, bundle, extraction and `EM_MTGPU` inspection: PASS;
* Julia LLVM 18 IR through vendor LLVM 14 MTGPU: NO_GO at the two retained
  parser errors;
* `make fix-whitespace`: executed and exited 2 only for the two accepted S1
  review tabs at lines 52 and 58;
* `git diff --check`: PASS.

Ignored downloads, depots and output objects remain under task-specific
`deps/srccache` and `usr` roots. No GPU, host installation, sudo, credential,
service, database, cleanup, deletion, push, deploy or formal acceptance was
performed.
