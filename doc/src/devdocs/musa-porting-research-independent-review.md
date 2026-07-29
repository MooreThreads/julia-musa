# Independent review: Julia on MUSA scope and dependencies

## Review identity and advisory

This is the independent research review produced by Gluon task
`b0090159-7a14-4259-b868-7ef8e313dea6`. It reviews exactly:

- candidate task: `05c0ce10-c108-4bf3-9ad1-cfea957641f3`;
- successful attempt: `5f463746-e4b9-487e-9caa-48edceedbe17`;
- base: `cc2f404a962ed06520a5e73493e5b84217bbf6f5`;
- result: `6c474d935ecf54e880411638811aace4e1220a26`;
- node: `ph327`; and
- candidate path:
  [`doc/src/devdocs/musa-porting-research.md`](musa-porting-research.md).

**Advisory verdict: GO.** The candidate is sufficiently cautious and
evidence-based to guide the next metadata and dependency-closure research
slice. `GO` does not authorize a Julia build, a MUSA compile or link, package
integration, GPU execution, a Julia-core change, or any correctness or
performance claim. The missing vendor, package, ABI, artifact, driver, device,
license, and compatibility evidence remains blocking at the gates identified
by the candidate.

This is an advisory only. Technical success of this review is **not formal
correctness approval**, and no accept, reject, or supersede decision or API was
called.

## Exact candidate and allowlist verification

The review worktree initially had an empty `git status --porcelain`, and
`git rev-parse HEAD` returned the exact result
`6c474d935ecf54e880411638811aace4e1220a26`.

Independent Git checks established:

- `git merge-base --is-ancestor <base> <result>` exited `0`;
- the result commit's only parent is the exact base;
- the base tree is `1ee298c699293b8ba633ce407997cab6891e5554`;
- the result tree is `6c41bb61b57275da078a8130278c18802d6cd64d`;
- `git diff --name-status <base>..<result>` returned exactly
  `A doc/src/devdocs/musa-porting-research.md`; and
- `git diff --check <base>..<result>` exited `0`.

Thus the candidate range is a clean one-commit descendant of the exact base,
and its allowlist is exactly the one required documentation file. No candidate
content was edited during this review.

## Evidence audit

All review commands were bounded CPU/source/text or Git metadata checks with
`OMP_NUM_THREADS=2`. The review did not configure or build Julia, execute
Julia, invoke a compiler or linker, fetch or install anything, or use a GPU.

### Bootstrap and build stages

The described dependency order is supported by tracked rules in
[`Makefile`](../../../Makefile): `julia-deps` enters `deps`; `julia-stdlib`
depends on it; `julia-src-*` depends on dependencies, the FemtoLisp boot
image, and the CLI; `julia-sysimg-*` adds Base, stdlibs, and top-level package
links; and the final release/debug targets add test libraries, the executable
link, and stdlib caches.

[`sysimage.mk`](../../../sysimage.mk) supports the stated image sequence.
`COMPILER_SRCS` includes `base/Base_compiler.jl`, other bootstrap Base files,
and `Compiler/src`; those sources produce `basecompiler`. The remaining Base,
frontend, and selected stdlib sources produce `sysbase`, which is then used
with generated precompile statements to produce `sys`. The optional
JuliaLowering image depends on `sys`. The archive-to-shared-library rule uses
the host link path. The native-compiler versus LLD distinction for system and
package images is stated in [`doc/src/devdocs/aot.md`](aot.md).

The candidate correctly keeps an external GPU-package compilation path
separate from Julia's bootstrap. Nothing inspected proves that a Julia rebuild
is needed for MUSA.

### LLVM and reusable compiler seams

[`deps/llvm.version`](../../../deps/llvm.version) pins LLVM `21.1.8` and the
Julia fork ref `julia-21.1.8-0`;
[`stdlib/libLLVM_jll/Project.toml`](../../../stdlib/libLLVM_jll/Project.toml)
records `21.1.8+0`. [`deps/llvm.mk`](../../../deps/llvm.mk) defaults source
builds to `host;NVPTX;AMDGPU;WebAssembly;BPF;AVR`, with no named MUSA target.
That absence establishes only the in-tree default target list, exactly as the
candidate says.

The CPU-only interpretation of `JULIA_CPU_TARGET` is supported by
[`doc/src/manual/environment-variables.md`](../manual/environment-variables.md)
and [`doc/src/devdocs/aot.md`](aot.md). The reusable compiler evidence is also
direct: [`src/aotcompile.cpp`](../../../src/aotcompile.cpp) explicitly names
GPUCompiler.jl as an external consumer of `jl_emit_native_impl`;
[`Compiler/src/types.jl`](../../../Compiler/src/types.jl) defines the
`AbstractInterpreter` API and optional overlay method table; and
[`Compiler/test/AbstractInterpreter.jl`](../../../Compiler/test/AbstractInterpreter.jl)
contains GPUCompiler- and CUDA-related regression cases.
[`base/genericmemory.jl`](../../../base/genericmemory.jl) assigns non-CPU
address-space semantics to the specific backend.

These facts justify trying the external-package seam first. They do not
establish that MUSA consumes any particular IR, that Julia's pinned LLVM can
produce a MUSA object, or that any ABI is compatible. The candidate consistently
leaves those as hypotheses or blockers.

### Ownership boundaries

[`doc/src/manual/distributed-computing.md`](../manual/distributed-computing.md)
classifies CUDA.jl, oneAPI.jl, and AMDGPU.jl as external packages that wrap
vendor stacks and compile or execute accelerator kernels. That is strong
repository evidence for presumptively assigning MUSA driver/runtime bindings,
discovery, contexts, memory, launch, synchronization, and device-facing
toolchain work to an external package.

The proposed escalation rule is appropriately narrow: Julia core becomes a
candidate owner only after a minimized external reproducer isolates a generic
compiler, runtime, FFI, exported-codegen, or pinned-LLVM defect. The candidate
does not claim that a CUDA.jl fork is compatible, that GPUCompiler already
supports MUSA, or that Julia core requires modification.

### Downloads, artifacts, host tools, and tests

The build guide documents the normal prebuilt-dependency path, the
`USE_BINARYBUILDER=0` source-build selection, the required host tools, the
risk of system-library overrides, and Julia's patched LLVM and libuv
expectations
([`doc/src/devdocs/build/build.md`](build/build.md)).
[`deps/Makefile`](../../../deps/Makefile) selects the dependency set and
system/BinaryBuilder modes. [`deps/tools/bb-install.mk`](../../../deps/tools/bb-install.mk)
constructs a platform-specific GitHub release URL, downloads into
`deps/srccache`, verifies a checksum, extracts the archive, and writes a
manifest. [`stdlib/Makefile`](../../../stdlib/Makefile) contains explicit
stdlib JLL metadata download rules.

Accordingly, the candidate is correct that `USE_BINARYBUILDER=0` is not itself
proof of an offline closure and that a source checkout alone is insufficient.
Its required closure covers Julia inputs, registries and external packages,
GPU compiler artifacts, the MUSA toolkit and device libraries, runtime
libraries, and the driver interface.

The top-level `test` target depends on a built Julia and dispatches through
[`test/Makefile`](../../../test/Makefile) to `test/runtests.jl`. The named
`compiler` and `Compiler` groups are present, and
[`Compiler/test/runtests.jl`](../../../Compiler/test/runtests.jl) calls
`Base.runtests(["Compiler"])`. These tests exercise relevant generic seams but
are not MUSA integration evidence.

### Missing MUSA evidence

The base-tree-only tracked search was repeated independently:

```text
git grep -n -i -E 'musa|moore[[:space:]_-]*threads|mthreads' <base> -- .
exit: 1
```

A base tree path inventory for top-level CUDA, AMDGPU, oneAPI, or GPUCompiler
package trees also found none (exit `1`). These are bounded negative results
about the exact Julia tree, not claims about external repositories or vendor
capabilities.

The candidate enumerates the material evidence still absent: exact MUSA
distribution and supported hosts; toolchain input and output formats; driver,
device, ISA, ABI, calling convention, address-space, data-layout, intrinsic,
device-library, atomics, synchronization, error, and debug requirements;
external Julia package provenance and compatibility; hashes and offline
layout; and licensing or redistribution permission. It makes no MUSA runtime,
support, correctness, or performance assertion in their absence.

### Minimum slices, oracle, denominator, risks, and DAG

The no-network CPU preflight is appropriately metadata-only: it verifies
identity, host-tool metadata, cache presence and digests, and static dependency
resolution without running Make, Julia, a compiler, linker, package manager,
or vendor executable. Absence is a hard stop, and `GO` at that gate is limited
to input closure.

The later progression is minimal and ordered: one side-effect-free integer
kernel compile; one-object device link; one assigned-GPU launch and copy-back;
then owner-specific escalation. Compile/link evidence does not require a Julia
source build. Each transition retains the pinned denominator and rejects
network access or undeclared inputs.

The `N = 257` integer oracle is deterministic and bounds-sensitive, requires
at least two workgroups, validates all outputs with an independent host
calculation, checks guards on both sides, requires successful API results and
the assigned device, and excludes performance. Its denominator freezes the
Julia tree and host binary, package environment and sources, toolchain and
device components, host platform, commands, environment, launch geometry,
source, inputs, guards, and expected digest. This is representative
integration evidence rather than circular acceptance of the device output.

The risks and unknowns match the evidence: missing backend/toolchain knowledge,
unsafe CUDA analogy, patched-LLVM coupling, unresolved package compatibility,
and absent hardware/legal evidence. The successor DAG gates metadata,
closure, compilation, linking, and a single-device oracle before broader
testing or performance work, with an explicit stop path.

## Severity-ranked findings and repairs

No critical, high, or medium-severity finding was identified.

1. **Low — a decision is labeled as a fact.** “Bootstrap cost is irrelevant
   until core ownership is proven” is a sensible scope decision, but
   “irrelevant” is not established by the cited dependency graph. The graph
   and cost exposure are facts; the decision to defer the build is a policy
   conclusion.

   **Repair:** relabel that risk entry as **DECISION** or **HYPOTHESIS**, while
   retaining the tracked Makefile/sysimage evidence for the graph.

2. **Low — the LLVM configuration sentence is slightly broader than its cited
   evidence.** `src/Makefile` visibly obtains LLVM headers, C/C++ flags,
   linker flags, and libraries through `LLVM_CONFIG_HOST`, but the phrase
   “target information” is not demonstrated by the cited Makefile queries.
   This does not affect the observed target list or the external-first
   conclusion.

   **Repair:** remove “target information” from that sentence or cite the
   separate tracked code that supplies the particular target datum intended.

3. **Low — the successor DAG does not draw the external-package failure branch
   explicitly.** The prose classifies an isolated failure into external MUSA
   package, shared GPU layer, Julia LLVM, or Julia core ownership, but the
   diagram after `S5` draws only hardening, shared-seam, and core/LLVM nodes.

   **Repair:** add an owner-specific external-MUSA-package reproducer/repair
   node, or state that such a failure loops back to the applicable `S3`–`S5`
   slice before proceeding.

4. **Low — the runtime oracle can be made more mechanically reproducible.**
   The denominator promises frozen launch dimensions, guards, and expected
   digest, but the research document does not yet prescribe a guard length or
   a separately generated expected vector/digest.

   **Repair:** in the authorized integration successor, pin both guard lengths,
   the exact buffer offset and byte layout, launch dimensions, the 257 expected
   `UInt32` values (or a digest produced by a separately reviewed scalar
   implementation), and the digest algorithm before GPU execution.

These repairs improve classification and reproducibility but do not undermine
the candidate's guarded ownership decision or its stop conditions. They may be
applied in a successor documentation task; this independent review does not
modify the candidate.

## Review limits

This review establishes only that the exact candidate accurately scopes the
next evidence-gathering work against the exact tracked Julia snapshot. It
cannot establish MUSA 5.2.0 behavior because no vendor documentation,
toolchain, external MUSA package, locked package environment, driver, device,
or GPU execution evidence was in scope or available from the tracked tree.

The advisory therefore remains:

```text
GO for metadata and offline dependency-closure research.
NO authorization and no technical claim for build, compile, link, runtime,
correctness, performance, MUSA support, or Julia-core modification.
```
